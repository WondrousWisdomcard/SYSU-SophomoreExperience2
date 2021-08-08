/*
题目：			写一个文件传输程序，通过一个TCP连接来传输一个文件及管理其元数据（包括：文件名、大小和日期等），保证文件传输正确无误。

程序定位：		Client.c 功能很简单，基于TCP协议与服务器连接，连接后接受它发送的一个文件，并显示文件信息。

传输的数据流格式的定义:	第一行为文件名（包括文件类型），如 test.txt
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
#include <netinet/in.h>
#include <netdb.h>

#define ERR_EXIT(m)         \
    do                      \
    {                       \
        perror(m);          \
        exit(EXIT_FAILURE); \
    } while (0)

#define CLIENT_NUM 10
#define BUFFER_SIZE 1024

int main()
{

    int ret;

    //socket
    printf("Socket...\n");
    struct hostent *host;
    char ip_str[INET_ADDRSTRLEN];
    printf("Enter the server's IPv4 address:");
    scanf("%s", ip_str);
    if ((host = gethostbyname(ip_str)) == NULL)
    {
        printf("Invalid IPv4 address.\n");
        exit(EXIT_FAILURE);
    }
    int port_num = 12340;
    printf("Server's official name = %s\n", host->h_name);

    char **ptr = host->h_addr_list;
    for (; *ptr != NULL; ptr++)
    {
        inet_ntop(host->h_addrtype, *ptr, ip_str, sizeof(ip_str));
        printf("         address = %s\n", ip_str);
    }

    int connect_fd = socket(AF_INET, SOCK_STREAM, 0);
    if (connect_fd == -1)
    {
        ERR_EXIT("socket()");
    }

    //connect
    printf("Connect...\n");
    struct sockaddr_in server_addr;
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(port_num);
    server_addr.sin_addr = *((struct in_addr *)host->h_addr);
    ret = connect(connect_fd, (struct sockaddr *)&server_addr, sizeof(struct sockaddr));
    if (ret == -1)
    {
        close(connect_fd);
        ERR_EXIT("connect()");
    }

    struct sockaddr_in connect_addr;
    int addr_len = sizeof(struct sockaddr);
    ret = getsockname(connect_fd, (struct sockaddr *)&connect_addr, &addr_len);
    if (ret == -1)
    {
        close(connect_fd);
        ERR_EXIT("getsockname()");
    }
    printf("Local IPv4 addr:port is %s:%hu\n", inet_ntoa(connect_addr.sin_addr), ntohs(connect_addr.sin_port));

    //recv
    char file_name[30], file_date[30];
    int file_size;
    int i = 0;

    char file_path[40] = "./\0";
    int fd;
    int recv_len;
    while (1)
    {
        char msg_buf[BUFFER_SIZE] = {0};
        recv_len = recv(connect_fd, msg_buf, BUFFER_SIZE, 0);
        if (recv_len <= 0)
        {
            printf("Receive finishing.\n");
            break;
        }
        if (i == 0)
        {
            i++;
            //printf("%s\n", msg_buf);
            sscanf(msg_buf, "%s\n%d\n%s", file_name, &file_size, file_date);
            strcat(file_path, file_name);
            fd = open(file_path, O_RDWR | O_CREAT | O_APPEND, S_IRWXU);
            if (fd == -1)
            {
                ERR_EXIT("open()");
            }
            ret = write(fd, msg_buf + 100, recv_len - 100);
        }
        else
        {
            ret = write(fd, msg_buf, recv_len);
        }
    }
    for (int i = 0; i < strlen(file_date); i++)
    {
        if (file_date[i] == '_')
        {
            file_date[i] = ' ';
        }
    }
    printf("Receive file: %s (%d Bytes)\n", file_name, file_size);
    printf("Receive at %s\n", file_date);
    //close
    printf("Close...\n");
    close(connect_fd);
    close(fd);
    return EXIT_SUCCESS;
}
