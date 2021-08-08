/*
题目：			写一个文件传输程序，通过一个TCP连接来传输一个文件及管理其元数据（包括：文件名、大小和日期等），保证文件传输正确无误。

程序定位:		Server.c 功能很简单，基于TCP协议连接一个客户机，链接后可以向它发送一个文件及其文件信息。 

传输数据流格式:	第一行为文件名（包括文件类型），如 test.txt
				第二行为文件大小，以 B 为单位
				第三行为文件发送日期，如 Mon_Apr_19_17:22:34_2021
				其余行为文件中的数据。
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <ifaddrs.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <ctype.h>
#include <libgen.h>

#define ERR_EXIT(m)         \
    do                      \
    {                       \
        perror(m);          \
        exit(EXIT_FAILURE); \
    } while (0)

#define CLIENT_NUM 10
#define BUFFER_SIZE 1024
// 每次传输1KB，若文件比较大，需要分次传输

// 获得文件发送时的时间
int get_time_string(char *t_str)
{
    time_t rawtime;
    struct tm *info;
    int ret = time(&rawtime);
    if (ret == -1)
    {
        ERR_EXIT("time()");
    }
    info = localtime(&rawtime);
    sprintf(t_str, "%s", asctime(info));
    return EXIT_SUCCESS;
}

// 本函数来自蔡国扬老师的课件，自动获得本地IP地址
int getipv4addr(char *ip_addr)
{
    struct ifaddrs *ifaddrsptr = NULL;
    struct ifaddrs *ifa = NULL;
    void *tmpptr = NULL;
    int ret;
    ret = getifaddrs(&ifaddrsptr);
    if (ret == -1)
    {
        ERR_EXIT("getifaddrs()");
    }
    for (ifa = ifaddrsptr; ifa != NULL; ifa = ifa->ifa_next)
    {
        if (!ifa->ifa_addr)
        {
            continue;
        }
        if (ifa->ifa_addr->sa_family == AF_INET)
        {
            tmpptr = &((struct sockaddr_in *)ifa->ifa_addr)->sin_addr;
            char addr_buf[INET_ADDRSTRLEN];
            inet_ntop(AF_INET, tmpptr, addr_buf, INET_ADDRSTRLEN);
            printf("%s IPv4 address %s\n", ifa->ifa_name, addr_buf);
            if (strcmp(ifa->ifa_name, "lo") != 0)
            {
                strcpy(ip_addr, addr_buf); // return the ipv4 address
            }
        }
    }
    if (ifaddrsptr != NULL)
    {
        freeifaddrs(ifaddrsptr);
    }
    return EXIT_SUCCESS;
}

//选择文件并检查权限，返回文件大小
int file_choose(char *file_name)
{
    int ret;
    while (1)
    {
        char name[128];
        printf("Enter the path of the file:");
        scanf("%s", file_name);
        ret = open(file_name, O_RDWR);
        if (ret == -1)
        {
            perror("open()");
            printf("Please try again\n");
        }
        else
        {
            break;
        }
    }
    return lseek(ret, 0, SEEK_END);
}

int main()
{

    int ret;

    //socket
    printf("Socket...\n");
    int server_fd = socket(AF_INET, SOCK_STREAM, 0);
    if (server_fd == -1)
    {
        ERR_EXIT("socket()");
    }

    //bind
    printf("Bind...\n");
    char ip_addr[INET_ADDRSTRLEN];
    int port_num;
    getipv4addr(ip_addr);
    port_num = 12340;
    struct sockaddr_in server_addr;
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = inet_addr(ip_addr);
    server_addr.sin_port = htons(port_num);
    bzero(&(server_addr.sin_zero), 8);
    int opt = 1;
    setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));
    ret = bind(server_fd, (struct sockaddr *)&server_addr, sizeof(struct sockaddr));
    if (ret == -1)
    {
        close(server_fd);
        ERR_EXIT("bind()");
    }

    //listen
    printf("Listen...\n");
    ret = listen(server_fd, CLIENT_NUM);
    if (ret == -1)
    {
        close(server_fd);
        ERR_EXIT("listen()");
    }

    //accept
    printf("Accept...\n");
    struct sockaddr_in connect_addr;
    socklen_t addr_len;
    int connect_fd = accept(server_fd, (struct sockaddr *)&connect_addr, &addr_len);
    if (connect_fd == -1)
    {
        ERR_EXIT("accept()");
    }

    printf("Succeed to connect client: IP_addr = %s, port = %hu\n", inet_ntoa(connect_addr.sin_addr), ntohs(connect_addr.sin_port));

    //send
    char file_path[128] = {0};
    char *file_name;
    char size_str[25] = {0};
    char time_str[40] = {0};
    int file_size = file_choose(file_path);
    if (file_size == -1)
    {
        ERR_EXIT("file_choose()");
    }

    sprintf(size_str, "%d", file_size);
    file_name = basename(file_path);
    get_time_string(time_str);
    printf("----------------\n");
    printf("File information\n");
    printf("File name: %s\n", file_name);
    printf("File size: %d\n", file_size);
    printf("Send Time: %s", time_str);
    printf("----------------\n");
    for (int i = 0; i < strlen(time_str); i++)
    {
        if (time_str[i] == ' ')
        {
            time_str[i] = '_';
        }
    }

    //FILE *stream;
    //stream = fopen(file_path,"r");
    //fseek(stream, 0, SEEK_SET);

    int fd = open(file_path, O_RDWR);
    int send_len = 0;
    int i = 0;
    while (1)
    {
        char send_buf[BUFFER_SIZE] = {0};
        if (i == 0)
        {
            //文件名称、大小、时间
            char msg_buf[BUFFER_SIZE] = {0};
            strncat(send_buf, file_name, strlen(file_name));
            strcat(send_buf, "\n");
            strncat(send_buf, size_str, strlen(size_str));
            strcat(send_buf, "\n");
            strncat(send_buf, time_str, strlen(time_str));
            strcat(send_buf, "\n");
            send_len = read(fd, send_buf + 100, BUFFER_SIZE - 100);
            send_len += 100;
            //printf("%d\n",send_len);
            if (send_len <= 0)
            {
                break;
            }
        }
        else
        {
            send_len = read(fd, send_buf, BUFFER_SIZE);
            //printf("%d\n",send_len);
            if (send_len <= 0)
            {
                break;
            }
            //printf("%s",send_buf);
        }
        //fgets(send_buf, BUFFER_SIZE-100, stream);
        if (send_len > 0)
        {
            ret = send(connect_fd, send_buf, send_len, 0);
        }
        if (ret == -1)
        {
            ERR_EXIT("send()");
        }
        i++;
    }
    printf("Sent successfully.\n");

    //close
    printf("Close...\n");
    close(server_fd);
    //fclose(stream);

    return EXIT_SUCCESS;
}
