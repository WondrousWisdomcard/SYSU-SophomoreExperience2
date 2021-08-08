#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <sys/signal.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <ifaddrs.h>
#include <time.h>

#define BUFFER_SIZE 1024

#define ERR_EXIT(m) \
    do { \
        perror(m); \
        exit(EXIT_FAILURE); \
    } while(0)

typedef struct msg{
	int request;
	int ack;
	int start;
	int end;
	int size;
	int stamp;
	struct timespec st_atim;  /* Time of last access */
	struct timespec st_mtim;  /* Time of last modification */
	struct timespec st_ctim;  /* Time of last status change */
	char file_name[80];
	char msg[512];
}MSG;

int getipv4addr(char *ip_addr){
    struct ifaddrs *ifaddrsptr = NULL;
    struct ifaddrs *ifa = NULL;
    void *tmpptr = NULL;
    int ret;

    ret = getifaddrs(&ifaddrsptr);
    if(ret == -1)
        ERR_EXIT("getifaddrs()");

    for(ifa = ifaddrsptr; ifa != NULL; ifa = ifa->ifa_next) {
        if(!ifa->ifa_addr) {
            continue;
        }
        if(ifa->ifa_addr->sa_family == AF_INET) {
            tmpptr = &((struct sockaddr_in *)ifa->ifa_addr)->sin_addr;
            char addr_buf[INET_ADDRSTRLEN];
            inet_ntop(AF_INET, tmpptr, addr_buf, INET_ADDRSTRLEN);
            if(strcmp(ifa->ifa_name, "lo") != 0)
                strcpy(ip_addr, addr_buf);
        }
    }

    if(ifaddrsptr != NULL) {
        freeifaddrs(ifaddrsptr);
    }

    return 0;
}

void print_real_time(struct timespec* tv){
	struct tm t;
	char date_time[64];
	strftime(date_time, sizeof(date_time), "%Y-%m-%d %H:%M:%S", localtime_r(&(tv->tv_sec), &t));
	printf("%s", date_time);
}

int recv_file(unsigned short port_num1,unsigned short port_num2){
	FILE* fd;
	int sim_lost,delay;
	char buff[BUFFER_SIZE],host_ipv4[80],filename[80];
	struct sockaddr_in request_addr,recv_addr,send_addr;
	MSG packet;
	socklen_t addr_len=sizeof(struct sockaddr_in);
	int count=0;
	int ret;
	getipv4addr(host_ipv4);
	int request_fd=socket(AF_INET,SOCK_DGRAM,0);//请求socket
	if(request_fd<0){
		perror("socket()");
		fclose(fd);
		return 1;
	}
	int recv_fd=socket(AF_INET,SOCK_DGRAM,0);//接收socket
	if(recv_fd<0){
		perror("socket()");
		fclose(fd);
		close(request_fd);
		return 1;
	}
	struct timeval tv_out;
	tv_out.tv_sec = 2;//等待2秒
	tv_out.tv_usec = 0;
	setsockopt(request_fd,SOL_SOCKET,SO_RCVTIMEO,&tv_out, sizeof(tv_out));//设置为2秒超时
	setsockopt(recv_fd,SOL_SOCKET,SO_RCVTIMEO,&tv_out, sizeof(tv_out));//设置为2秒超时
	
	
	bzero(&request_addr,addr_len);
	request_addr.sin_family=AF_INET;
	request_addr.sin_port = htons(port_num1);//接收请求的端口
	request_addr.sin_addr.s_addr=inet_addr(host_ipv4);
	ret=bind(request_fd,(struct sockaddr*)&request_addr,addr_len);
	if(ret<0){
		perror("bind()");
		fclose(fd);
		close(request_fd);
		close(recv_fd);
		return 1;
	}
	printf("request socket bind!\nip:%s\nport:%hu\n",host_ipv4,ntohs(request_addr.sin_port));
	
	bzero(&recv_addr,addr_len);
	recv_addr.sin_family=AF_INET;
	recv_addr.sin_port = htons(port_num2);//接收文件的端口
	recv_addr.sin_addr.s_addr=inet_addr(host_ipv4);
	ret=bind(recv_fd,(struct sockaddr*)&recv_addr,addr_len);
	if(ret<0){
		perror("bind()");
		fclose(fd);
		close(request_fd);
		close(recv_fd);
		return 1;
	}
	printf("receive socket bind!\nip:%s\nport:%hu\n",host_ipv4,ntohs(recv_addr.sin_port));
	int lost;
	while(1){
		printf("Waiting request\n");
		ret=recvfrom(request_fd,&packet,sizeof(packet),0,(struct sockaddr*)&send_addr,&addr_len);//接收请求
		lost=rand()%2+1;
		if(ret<=0||packet.request==0||lost==1){
			perror("recvfrom()");
		}else{
			if(strlen(buff)>0){
				strcpy(filename,packet.file_name);
			}
			printf("Received request from %s!,it wants to send:%s\n",inet_ntoa(send_addr.sin_addr),filename);
			printf("sending ack to sender:%s\n",inet_ntoa(send_addr.sin_addr));
			packet.ack=1;
			ret=sendto(recv_fd,&packet,sizeof(packet),0,(struct sockaddr*)&send_addr,addr_len);
			while(1){//通知发送方获得了传送许可
				lost=rand()%10+1;
				ret=recvfrom(recv_fd,&packet,sizeof(packet),0,(struct sockaddr*)&send_addr,&addr_len);
				if(ret<0||lost!=4){
					packet.ack=1;
					ret=sendto(recv_fd,&packet,sizeof(packet),0,(struct sockaddr*)&send_addr,addr_len);
					printf("Acknowledgement lost\n");
				}else{
					if(packet.start==1)break;//这表明发送方已经开始传送文件
				}
			}
			if(strlen(buff)>0){
				int total_size=0;
				sprintf(buff,"./%s",filename);//建立文件
				FILE* fd=fopen(buff,"w+");//会覆盖同名文件
				//跟发送端说：你获得了传送准许
				int index=0;
				int count=0;
				sprintf(buff,"bad%d",index);//发送这一字符串会使得接收方无论如何都会重新发送第一个包，避免跳过
				while(1){
					ret=recvfrom(recv_fd,&packet,sizeof(packet),0,(struct sockaddr*)&send_addr,&addr_len);
					sim_lost=rand()%50+1;
					delay=rand()%3+1;
					if(ret<0||packet.stamp<index||sim_lost==25){//重新说一遍
						perror("recvfrom()");
						ret=sendto(recv_fd,buff,BUFFER_SIZE,0,(struct sockaddr*)&send_addr,addr_len);
						count++;
					}else{
						if(sim_lost==2){
							sleep(delay);
						}
						if(ret!=sizeof(packet)||sim_lost==42){//模拟包接收不全
							printf("half packet!:%d\n",index);
							sprintf(buff,"bad%d",index);
							ret=sendto(recv_fd,buff,BUFFER_SIZE,0,(struct sockaddr*)&send_addr,addr_len);
						}else{
							printf("good packet!:%d\n",index);
							sprintf(buff,"ok%d",index);
							ret=sendto(recv_fd,buff,BUFFER_SIZE,0,(struct sockaddr*)&send_addr,addr_len);
							total_size+=fwrite(&(packet.msg),sizeof(char),packet.size,fd);
							index++;//开始接收下一个包
							count=0;
							if(packet.end==1){//打印成功信息以及文件属性
								for(int i=1;i<=10;i++){//连续发送十个再见包，断开传输
									sprintf(buff,"ok%d",index);
									ret=sendto(recv_fd,buff,BUFFER_SIZE,0,(struct sockaddr*)&send_addr,addr_len);
									usleep(50000);
								}
								printf("Receive ALL!\n");
								printf("filename:%s\nsize:%dBytes\nInitial access time:",filename,total_size);
								print_real_time(&(packet.st_atim));
								printf("\nInitial modified time:");
								print_real_time(&(packet.st_mtim));
								printf("\nInitial change time:");
								print_real_time(&(packet.st_ctim));
								printf("\n");
								fclose(fd);
								break;
							}
						}
					}
					if(count==100){
						printf("Bad transmission!\n");
						fclose(fd);
						break;
					}
				}
			}
			while(recvfrom(request_fd,&packet,sizeof(packet),0,(struct sockaddr*)&send_addr,&addr_len)>0);
		}
	}
	printf("Sending ends successfully!\n");
	fclose(fd);
	close(request_fd);
	close(recv_fd);
	return 0;
}

int main(){
	srand(time(0));
	unsigned short port_num1,port_num2;
	printf("port for request:");
	scanf("%hu",&port_num1);
	printf("port for recv:");
	scanf("%hu",&port_num2);
	recv_file(port_num1,port_num2);
	return 0;
}
