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

#define BUFFER_SIZE 1024
#define NICKNAME_L 11
#define MSG_SIZE BUFFER_SIZE + NICKNAME_L + 4
#define ERR_EXIT(m)         \
    do                      \
    {                       \
        perror(m);          \
        exit(EXIT_FAILURE); \
    } while (0)

/* asynchronous send-receive version; separated input terminal*/

int main(int argc, char *argv[])
{
    char fifoname[80], nickname[80];
    int fdr, connect_fd;
    char ip_name_str[INET_ADDRSTRLEN];
    uint16_t port_num;
    char stdin_buf[BUFFER_SIZE], msg_buf[MSG_SIZE];
    int sendbytes, recvbytes, ret;
    char clr;
    struct hostent *host;
    struct sockaddr_in server_addr, connect_addr;
    socklen_t addr_len;
    pid_t childpid;

    if (argc < 2)
    {
        printf("Usage: ./a.out pathname\n");
        return EXIT_FAILURE;
    }
    strcpy(fifoname, argv[1]);
    if (access(fifoname, F_OK) == -1)
    {
        if (mkfifo(fifoname, 0666) != 0)
        {
            perror("mkfifo()");
            exit(EXIT_FAILURE);
        }
        else
            printf("new fifo %s named pipe created\n", fifoname);
    }

    fdr = open(fifoname, O_RDWR); /* blocking write and blocking read in default */
    if (fdr < 0)
    {
        perror("pipe read open()");
        exit(EXIT_FAILURE);
    }

    printf("Input server's hostname/ipv4: "); /* www.baidu.com or an ipv4 address */
    scanf("%s", stdin_buf);
    while ((clr = getchar()) != '\n' && clr != EOF)
        ; /* clear the stdin buffer */
    printf("Input server's port number: ");
    scanf("%hu", &port_num);
    while ((clr = getchar()) != '\n' && clr != EOF)
        ;

    if ((host = gethostbyname(stdin_buf)) == NULL)
    {
        printf("invalid name or ip-address\n");
        exit(EXIT_FAILURE);
    }
    printf("server's official name = %s\n", host->h_name);
    char **ptr = host->h_addr_list;
    for (; *ptr != NULL; ptr++)
    {
        inet_ntop(host->h_addrtype, *ptr, ip_name_str, sizeof(ip_name_str));
        printf("\tserver address = %s\n", ip_name_str);
    }
    /*creat connection socket*/
    if ((connect_fd = socket(AF_INET, SOCK_STREAM, 0)) == -1)
    {
        ERR_EXIT("socket()");
    }
    /* set sockaddr_in of server-side */
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(port_num);
    server_addr.sin_addr = *((struct in_addr *)host->h_addr);
    bzero(&(server_addr.sin_zero), 8);

    addr_len = sizeof(struct sockaddr);
    ret = connect(connect_fd, (struct sockaddr *)&server_addr, addr_len); /* connect to server */
    if (ret == -1)
    {
        close(connect_fd);
        ERR_EXIT("connect()");
    }
    /* connect_fd is assigned a port_number after connecting */
    addr_len = sizeof(struct sockaddr);
    ret = getsockname(connect_fd, (struct sockaddr *)&connect_addr, &addr_len);
    if (ret == -1)
    {
        close(connect_fd);
        ERR_EXIT("getsockname()");
    }
    port_num = ntohs(connect_addr.sin_port);
    strcpy(ip_name_str, inet_ntoa(connect_addr.sin_addr));
    printf("Local port: %hu, IP addr: %s\n", port_num, ip_name_str);

    strcpy(ip_name_str, inet_ntoa(server_addr.sin_addr));

    childpid = fork();
    if (childpid < 0)
        ERR_EXIT("fork()");
    if (childpid > 0)
    { /* parent pro */
        while (1)
        {                                            /* sending cycle */
            ret = read(fdr, stdin_buf, BUFFER_SIZE); /* blocking read named pipe; read data from input terminal */
            if (ret <= 0)
            {
                perror("read()");
                break;
            }
            stdin_buf[BUFFER_SIZE - 1] = 0;
            sendbytes = send(connect_fd, stdin_buf, BUFFER_SIZE, 0); /* blocking socket send */
            if (sendbytes <= 0)
            {
                printf("sendbytes = %d. Connection terminated ...\n", sendbytes);
                break;
            }
            if (strncmp(stdin_buf, "#0", 2) == 0)
            {
                memset(stdin_buf, 0, BUFFER_SIZE);
                strcpy(stdin_buf, "I quit ... ");
                sendbytes = send(connect_fd, stdin_buf, BUFFER_SIZE, 0); /* blocking socket send */
                break;
            }
        }
        close(fdr);
        close(connect_fd);
        kill(childpid, SIGKILL);
    }
    else
    { /* child pro */
        while (1)
        {                                                       /* receiving cycle */
            recvbytes = recv(connect_fd, msg_buf, MSG_SIZE, 0); /* blocking socket recv */
            if (recvbytes <= 0)
            {
                printf("recvbytes = %d. Connection terminated ...\n", recvbytes);
                break;
            }
            msg_buf[MSG_SIZE - 1] = 0;
            printf("%s\n", msg_buf);
            ret = strncmp(msg_buf, "Console: #0", 11); /* be kicked out */
            if (ret == 0)
            {
                break;
            }
        }
        close(connect_fd);
        kill(getppid(), SIGKILL);
    }

    return EXIT_SUCCESS;
}
