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

int getipv4addr(char *ip_addr)
{
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
        if(ifa->ifa_addr->sa_family == AF_INET) { /* IP4 */
            tmpptr = &((struct sockaddr_in *)ifa->ifa_addr)->sin_addr;
            char addr_buf[INET_ADDRSTRLEN];
            inet_ntop(AF_INET, tmpptr, addr_buf, INET_ADDRSTRLEN);
            //printf("%s IPv4 address %s\n", ifa->ifa_name, addr_buf);
            if(strcmp(ifa->ifa_name, "lo") != 0)
                strcpy(ip_addr, addr_buf); /* return the ipv4 address */
        }
    }

    if(ifaddrsptr != NULL) {
        freeifaddrs(ifaddrsptr);
    }

    return EXIT_SUCCESS;
}

void print_real_time(struct timespec* tv){
	struct tm t;
	char date_time[64];
	strftime(date_time, sizeof(date_time), "%Y-%m-%d %H:%M:%S", localtime_r(&(tv->tv_sec), &t));
	printf("%s", date_time);
}

int send_file_to(char* pathname,char* name,char* ipv4,unsigned short port_num){
	FILE* fd=fopen(pathname,"r");
	char buff[BUFFER_SIZE],host_ipv4[80];
	struct sockaddr_in recv_addr;
	MSG packet;
	socklen_t addr_len=sizeof(struct sockaddr_in);
	int count=0;
	int ret;
	if(fd==NULL){
		perror("fopen()");
		return 1;
	}
	strcpy(packet.file_name,name);
	getipv4addr(host_ipv4);
	int connect_fd=socket(AF_INET,SOCK_DGRAM,0);
	if(connect_fd<0){
		perror("socket()");
		fclose(fd);
		return 1;
	}
	struct timeval tv_out;
	tv_out.tv_sec = 2;//等待2秒
	tv_out.tv_usec = 0;
	setsockopt(connect_fd,SOL_SOCKET,SO_RCVTIMEO,&tv_out, sizeof(tv_out));//设置为2秒超时
	
	
	bzero(&recv_addr,addr_len);
	recv_addr.sin_family=AF_INET;
	recv_addr.sin_port = htons(1234);
	recv_addr.sin_addr.s_addr=inet_addr(host_ipv4);
	ret=bind(connect_fd,(struct sockaddr*)&recv_addr,addr_len);
	if(ret<0){
		perror("bind()");
		fclose(fd);
		close(connect_fd);
		return 1;
	}
	printf("Bind!\nip:%s\nport:%hu\n",host_ipv4,ntohs(recv_addr.sin_port));
	bzero(&recv_addr,addr_len);
	recv_addr.sin_family = AF_INET;
	recv_addr.sin_port = htons(port_num);
	recv_addr.sin_addr.s_addr = inet_addr(ipv4);
	printf("Dest ip:%s\nDest port:%hu\nFIle:%s\n",ipv4,ntohs(recv_addr.sin_port),packet.file_name);
	struct stat status;
	if(stat(pathname,&status)<0){
		perror("stat()");
	}
	packet.st_atim=status.st_atim;  /* Time of last access */
	packet.st_mtim=status.st_mtim;  /* Time of last modification */
	packet.st_ctim=status.st_ctim;  /* Time of last status change */
	
	packet.request=1;
	ret=sendto(connect_fd,&packet,sizeof(packet),0,(struct sockaddr*)&recv_addr,addr_len);//发送请求(文件名)
	count=0;
	while(1){
		struct sockaddr_in temp;
		bzero(&temp,sizeof(struct sockaddr_in));
		ret=recvfrom(connect_fd,&packet,sizeof(packet),0,(struct sockaddr*)&temp,&addr_len);
		int lost=rand()%2+1;
		if(ret<0||lost==1){//有可能第一个包就丢了
			printf("No respond from receiver\n");
			perror("recvfrom()");
			packet.request=1;
			ret=sendto(connect_fd,&packet,sizeof(packet),0,(struct sockaddr*)&recv_addr,addr_len);
			count++;
		}else{
			if(packet.ack==1){//获得准许
				recv_addr=temp;
				printf("Get permission for sending\n");
				packet.start=1;
				ret=sendto(connect_fd,&packet,sizeof(packet),0,(struct sockaddr*)&recv_addr,addr_len);
				break;
			}
		}
		if(count==1000){
			printf("no respond!\n");
			fclose(fd);
			close(connect_fd);
			return 1;
		}
	}
	int index=0;
	char ack1[80],ack2[80];
	int sim_lost,delay;
	packet.request=0;
	
	while(!feof(fd)){
		ret=fread(&(packet.msg),sizeof(char),512,fd);//读取
		if(ret<0){
			perror("fread()");
			break;
		}
		if(feof(fd)){
			packet.end=1;
		}else{
			packet.end=0;
		}
		packet.size=ret;
		packet.stamp=index;
		packet.start=1;
		sprintf(ack1,"ok%d",index);
		sprintf(ack2,"bad%d",index);//构造这一包的确认指令
		ret=sendto(connect_fd,&packet,sizeof(packet),0,(struct sockaddr*)&recv_addr,addr_len);
		while(1){
			ret=recvfrom(connect_fd,buff,BUFFER_SIZE,0,(struct sockaddr*)&recv_addr,&addr_len);
			sim_lost=rand()%25+1;
			delay=rand()%3+1;
			if(ret<0||sim_lost==12){
				perror("recvfrom()");
				ret=sendto(connect_fd,&packet,sizeof(packet),0,(struct sockaddr*)&recv_addr,addr_len);
				count++;
				printf("No ack from receiver for packet:%d\n",index);
			}else{
				if(sim_lost==25){
					sleep(delay);
				}
				if(strcmp(ack1,buff)==0){//获得积极应答
					printf("Good sending:%d\n",index);
					count=0;
					index++;//开始发送下一个包
					break;
				}
				if(strcmp(ack2,buff)==0){
					printf("Bad sending\n");
					ret=sendto(connect_fd,&packet,sizeof(packet),0,(struct sockaddr*)&recv_addr,addr_len);
				}
			}
			if(count==100){
				printf("bad transmission!\nQuit!\n");
				fclose(fd);
				close(connect_fd);
				return 1;
			}
		}
	}
	printf("Sending ends successfully!\n");
	fclose(fd);
	close(connect_fd);
	return 0;
}

int main(){
        srand(time(0));
	char pathname[80],ipv4[80],name[80],clr;
	unsigned short port;
	while(1){
		printf("Dest ip:");
		scanf("%s",ipv4);
		scanf("%c",&clr);
		printf("Dest port:");
		scanf("%hu",&port);
		scanf("%c",&clr);
		printf("filepath:");
		scanf("%s",pathname);
		scanf("%c",&clr);
		printf("filename:");
		scanf("%s",name);
		scanf("%c",&clr);
		send_file_to(pathname,name,ipv4,port);
		
	}
	return 0;
}
