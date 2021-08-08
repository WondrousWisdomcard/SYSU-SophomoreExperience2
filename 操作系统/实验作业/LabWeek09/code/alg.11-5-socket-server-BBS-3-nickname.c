#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <ifaddrs.h>
#include <sys/shm.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <ctype.h>
#include <sys/time.h>

#define BUFFER_SIZE 1024                      /* each pipe has at least 64 blocks for this sze */
#define NICKNAME_L 11                         /* 10 chars for nickname */
#define MSG_SIZE BUFFER_SIZE + NICKNAME_L + 4 /* msg exchanged between pipe_data() and recv_send_data() */
#define MAX_QUE_CONN_NM 5                     /* length of ESTABLISHED queue */
#define MAX_CONN_NUM 10                       /* cumulative number of connecting processes */
#define STAT_L 15
#define STAT_EMPTY 0
#define STAT_ACCEPTED 1
#define STAT_NORMAL 2
#define STAT_ENDED -1

#define ERR_EXIT(m)         \
    do                      \
    {                       \
        perror(m);          \
        exit(EXIT_FAILURE); \
    } while (0)

/* one server, m clients BBS, with private chatting */

struct
{
    int stat;
    char nickname[NICKNAME_L];
} sn_attri[MAX_CONN_NUM + 1];

int connect_sn, max_sn; /* from 1 to MAX_CONN_NUM */
int server_fd, connect_fd[MAX_CONN_NUM + 1];
int fd[MAX_CONN_NUM + 1][2];
/* ordinary pipe: pipe_data() gets max_sn from main() by fd[0][0]
                   recv_send_data(sn) get send_buf from pipe_data() by fd[sn][0], 0<sn<MAX_CONN_NUM+1 */
int fd_stat[2]; /* ordinary pipe: pipe_data() gets stat of connect_sn from main() */
int fd_msg[2];  /* ordinary pipe: pipe_data() gets message of connect_sn from recv_send_data() */
int fdr;        /* named pipe: pipe_data() gets stdin_buf from input terminal */
struct sockaddr_in server_addr, connect_addr;

char *stat_descriptor(int stat, char *stat_str)
{
    switch (stat)
    {
    case 0:
        strcpy(stat_str, "STAT_EMPTY");
        break;
    case 1:
        strcpy(stat_str, "STAT_ACCEPTD");
        break;
    case 2:
        strcpy(stat_str, "STAT_NORMAL");
        break;
    case -1:
        strcpy(stat_str, "STAT_ENDED");
        break;
    default:
        strcpy(stat_str, "STAT_UNKNOWN");
        break;
    }

    return stat_str;
}

void sleep_ms(long int timegap_ms)
{
    struct timeval t;
    /*  __time_t tv_sec;
    __suseconds_t tv_usec;
*/
    long curr_s, curr_ms, end_ms;

    gettimeofday(&t, 0);
    curr_s = t.tv_sec;
    curr_ms = (long)(t.tv_sec * 1000);
    end_ms = curr_ms + timegap_ms;
    while (1)
    {
        gettimeofday(&t, 0);
        curr_ms = (long)(t.tv_sec * 1000);
        if (curr_ms > end_ms)
        {
            break;
        }
    }
    return;
}

int getipv4addr(char *ip_addr)
{
    struct ifaddrs *ifaddrsptr = NULL;
    struct ifaddrs *ifa = NULL;
    void *tmpptr = NULL;
    int ret;

    ret = getifaddrs(&ifaddrsptr);
    if (ret == -1)
        ERR_EXIT("getifaddrs()");

    for (ifa = ifaddrsptr; ifa != NULL; ifa = ifa->ifa_next)
    {
        if (!ifa->ifa_addr)
        {
            continue;
        }
        if (ifa->ifa_addr->sa_family == AF_INET)
        { /* IP4 */
            tmpptr = &((struct sockaddr_in *)ifa->ifa_addr)->sin_addr;
            char addr_buf[INET_ADDRSTRLEN];
            inet_ntop(AF_INET, tmpptr, addr_buf, INET_ADDRSTRLEN);
            printf("%s IPv4 address %s\n", ifa->ifa_name, addr_buf);
            if (strcmp(ifa->ifa_name, "lo") != 0)
                strcpy(ip_addr, addr_buf); /* return the ipv4 address */
        }
        else if (ifa->ifa_addr->sa_family == AF_INET6)
        { /* IP6 */
            tmpptr = &((struct sockaddr_in6 *)ifa->ifa_addr)->sin6_addr;
            char addr_buf[INET6_ADDRSTRLEN];
            inet_ntop(AF_INET6, tmpptr, addr_buf, INET6_ADDRSTRLEN);
            printf("%s IPv6 address %s\n", ifa->ifa_name, addr_buf);
        }
    }

    if (ifaddrsptr != NULL)
    {
        freeifaddrs(ifaddrsptr);
    }

    return EXIT_SUCCESS;
}

void pipe_data(void)
{
    /* get sidin_buf from input terminal
   update max_sn from main()
   update sn_stat from main() - STAT_EMPTY->STAT_NORMAL
   update sn_stat from recv_send_data() STAT_NORMAL->STAT_ENDED
   update sn_nickname from recv_send_data()
   select connect_sn by the descritor @**** in start of send_buf */

    char send_buf[BUFFER_SIZE], stat_buf[BUFFER_SIZE], stdin_buf[BUFFER_SIZE];
    char msg_buf[MSG_SIZE]; /* sn(4)nickname(10)recv_buff(BUFFER_SIZE) */
    int flags, sn, ret, i, stat;
    char nickname[NICKNAME_L], old_nickname[NICKNAME_L], stat_str[STAT_L];

    flags = fcntl(fd[0][0], F_GETFL, 0);
    fcntl(fd[0][0], F_SETFL, flags | O_NONBLOCK); /* set to non-blocking read ord-pipe */
    flags = fcntl(fd_stat[0], F_GETFL, 0);
    fcntl(fd_stat[0], F_SETFL, flags | O_NONBLOCK); /* set to non-blocking read ord-pipe */
    flags = fcntl(fd_msg[0], F_GETFL, 0);
    fcntl(fd_msg[0], F_SETFL, flags | O_NONBLOCK); /* set to non-blocking read ord-pipe */
    flags = fcntl(fdr, F_GETFL, 0);
    fcntl(fdr, F_SETFL, flags | O_NONBLOCK); /* set to non-blocking read nam-pipe */

    while (1)
    {
        while (1)
        {                                          /* get the last current max_sn from main() */
            ret = read(fd[0][0], &sn, sizeof(sn)); /* non-blocking read ord-pipe from main() */
            if (ret <= 0)
            { /* pipe empty */
                break;
            }
            max_sn = sn;
            printf("max_sn changed to: %d\n", max_sn);
        }

        while (1)
        {                                                  /* update sn_stat from main() */
            ret = read(fd_stat[0], stat_buf, BUFFER_SIZE); /* non-blocking read ord-pipe from main() */
            if (ret <= 0)
            { /* pipe empty */
                break;
            }
            sscanf(stat_buf, "%d,%d", &sn, &stat);
            printf("SN stat changed: sn = %d, stat: %d -> %d\n", sn, sn_attri[sn].stat, stat);
            sn_attri[sn].stat = stat;
        }

        while (1)
        {                                             /* update sn_stat and nickname from recv_send_data(), or brocast msg to all sn */
            ret = read(fd_msg[0], msg_buf, MSG_SIZE); /* non-blocking read ord-pipe from recv_send_data() */
            if (ret <= 0)
            { /* pipe empty */
                break;
            }
            sscanf(msg_buf, "%4d%s", &sn, stat_buf);

            if (sn_attri[sn].stat != STAT_ACCEPTED && sn_attri[sn].stat != STAT_NORMAL)
            {
                break;
            }

            if (sn_attri[sn].stat == STAT_ACCEPTED && msg_buf[4] != '#')
            {
                memset(msg_buf, 0, MSG_SIZE);
                sprintf(msg_buf, "Console: pls initiate your nickname by [#1nickname] first.");
                ret = write(fd[sn][1], msg_buf, MSG_SIZE); /* non-blocking write ord-pipe */
                if (ret <= 0)
                {
                    printf("sn = %d write error, message missed ...\n", sn);
                }
                break;
            }

            if (msg_buf[4] == '#')
            {

                if (msg_buf[5] == '0')
                { /* #0: terminating the connect_fd */
                    stat = STAT_ENDED;
                    printf("SN stat changed: sn = %d, stat: %d -> %d\n", sn, sn_attri[sn].stat, stat);
                    sn_attri[sn].stat = stat;
                }

                if (msg_buf[5] == '1')
                { /* #1name: renaming the nickname */
                    strncpy(nickname, &msg_buf[6], NICKNAME_L);
                    for (i = 0; i < NICKNAME_L - 1; i++)
                    {
                        if (nickname[i] == ' ')
                        {
                            nickname[i] = '_';
                        }
                        if (nickname[i] == '\n')
                        {
                            nickname[i] = 0;
                        }
                    }
                    nickname[i] = 0;
                    ret = strcmp("Anonymous", nickname);
                    if (ret == 0)
                    {
                        memset(msg_buf, 0, MSG_SIZE);
                        sprintf(msg_buf, "Console: invalid nickname: %s", nickname);
                        ret = write(fd[sn][1], msg_buf, MSG_SIZE); /* non-blocking write ord-pipe */
                        if (ret <= 0)
                        {
                            printf("sn = %d write error, message missed ...\n", sn);
                        }
                        break;
                    }
                    for (i = 0; i <= max_sn; i++)
                    {                                                 /* sn_attri[0].nickname = "Console" */
                        ret = strcmp(sn_attri[i].nickname, nickname); /* whatever ENDED or not */
                        if (ret == 0)
                        {
                            memset(msg_buf, 0, MSG_SIZE);
                            sprintf(msg_buf, "Console: this nickname occupied: %s", nickname);
                            ret = write(fd[sn][1], msg_buf, MSG_SIZE); /* non-blocking write ord-pipe */
                            if (ret <= 0)
                            {
                                printf("sn = %d write error, message missed ...\n", sn);
                            }
                            break;
                        }
                    }
                    if (i > max_sn)
                    {
                        printf("SN stat changed: sn = %d, nickname: %s -> %s\n", sn, sn_attri[sn].nickname, nickname);
                        strncpy(old_nickname, sn_attri[sn].nickname, NICKNAME_L);
                        strncpy(sn_attri[sn].nickname, nickname, NICKNAME_L);
                        stat = sn_attri[sn].stat; /* save the old stat */
                        sn_attri[sn].stat = STAT_NORMAL;
                        memset(msg_buf, 0, MSG_SIZE);
                        if (stat == STAT_ACCEPTED)
                        {
                            sprintf(msg_buf, "Console: welcome, %s", sn_attri[sn].nickname);
                        }
                        else
                        {
                            sprintf(msg_buf, "Console: %s changed nickname to %s", old_nickname, sn_attri[sn].nickname);
                        }
                        for (sn = 1; sn <= max_sn; sn++)
                        { /* message sent to all sn's by ord-pipes fd[sn][1] */
                            if (sn_attri[sn].stat == STAT_NORMAL)
                            {
                                flags = fcntl(fd[sn][1], F_GETFL, 0);
                                fcntl(fd[sn][1], F_SETFL, flags | O_NONBLOCK);
                                ret = write(fd[sn][1], msg_buf, MSG_SIZE); /* non-blocking write ord-pipe */
                                if (ret <= 0)
                                {
                                    printf("sn = %d write error, message missed ...\n", sn);
                                }
                            }
                        }
                    }
                }

                if (msg_buf[5] == '2')
                { /* #1: listing all connectors of the BBS */
                    memset(msg_buf, 0, MSG_SIZE);
                    sprintf(msg_buf, "\n====   connector list   =====");
                    ret = write(fd[sn][1], msg_buf, MSG_SIZE); /* non-blocking write ord-pipe */
                    if (ret <= 0)
                    {
                        printf("sn = %d write error, message missed ...\n", sn);
                    }
                    for (i = 0; i <= max_sn; i++)
                    { /* sn_attri[0].nickname = "Console" */
                        memset(msg_buf, 0, MSG_SIZE);
                        sprintf(msg_buf, "sn = %d, stat = %s, nickname = %s", i, stat_descriptor(sn_attri[i].stat, stat_str), sn_attri[i].nickname);
                        ret = write(fd[sn][1], msg_buf, MSG_SIZE); /* non-blocking write ord-pipe */
                        if (ret <= 0)
                        {
                            printf("sn = %d write error, message missed ...\n", sn);
                            break;
                        }
                    }
                    memset(msg_buf, 0, MSG_SIZE);
                    sprintf(msg_buf, "========\n");
                    ret = write(fd[sn][1], msg_buf, MSG_SIZE); /* non-blocking write ord-pipe */
                    if (ret <= 0)
                    {
                        printf("sn = %d write error, message missed ...\n", sn);
                    }
                }
                /* ignore the message from recv_send_data() otherwise */
            }
            else if (msg_buf[4] == '@')
            {
                for (i = 0; i < NICKNAME_L - 1; i++)
                {
                    nickname[i] = msg_buf[5 + i];
                    if (msg_buf[5 + i] == 0 || msg_buf[5 + i] == ' ')
                    {
                        break;
                    }
                }
                nickname[i] = 0;
                if (msg_buf[5 + i] == ' ')
                {
                    i++;
                }
                strcpy(stdin_buf, &msg_buf[5 + i]);

                memset(msg_buf, 0, MSG_SIZE);
                sprintf(msg_buf, "%s@: %s", sn_attri[sn].nickname, stdin_buf);
                for (sn = 1; sn <= max_sn; sn++)
                { /* message sent to all sn's by ord-pipes fd[sn][1] */
                    if (sn_attri[sn].stat == STAT_NORMAL && strcmp(sn_attri[sn].nickname, nickname) == 0)
                    {
                        flags = fcntl(fd[sn][1], F_GETFL, 0);
                        fcntl(fd[sn][1], F_SETFL, flags | O_NONBLOCK); /* set to non-blocking write ord-pipe */
                        ret = write(fd[sn][1], msg_buf, MSG_SIZE);     /* non-blocking write ord-pipe */
                        if (ret <= 0)
                        {
                            printf("sn = %d write error, message missed ...\n", sn);
                        }
                    }
                }
            }
            else
            {
                strcpy(stdin_buf, &msg_buf[4]);
                memset(msg_buf, 0, MSG_SIZE);
                sprintf(msg_buf, "%s: %s", sn_attri[sn].nickname, stdin_buf);
                for (sn = 1; sn <= max_sn; sn++)
                { /* message sent to all sn's by ord-pipes fd[sn][1] */
                    if (sn_attri[sn].stat == STAT_NORMAL)
                    {
                        flags = fcntl(fd[sn][1], F_GETFL, 0);
                        fcntl(fd[sn][1], F_SETFL, flags | O_NONBLOCK); /* set to non-blocking write ord-pipe */
                        ret = write(fd[sn][1], msg_buf, MSG_SIZE);     /* non-blocking write ord-pipe */
                        if (ret <= 0)
                        {
                            printf("sn = %d write error, message missed ...\n", sn);
                        }
                    }
                }
            }
        }

        while (1)
        {                                            /* read from input terminal and brocast to all sn */
            ret = read(fdr, stdin_buf, BUFFER_SIZE); /* non-blocking read nam-pipe from input terminal */
            if (ret <= 0)
            {
                break;
            }
            if (stdin_buf[0] == '@')
            {
                sn = atoi(&stdin_buf[1]);
                if (sn > 0 && sn <= max_sn && sn_attri[sn].stat == STAT_NORMAL)
                {
                    for (i = 1; isdigit(stdin_buf[i]); i++)
                        ;
                    if (stdin_buf[i] == '#' && stdin_buf[i + 1] == '0')
                    { /* #0: terminating the connect_fd */
                        stat = STAT_ENDED;
                        printf("SN stat changed: sn = %d, stat: %d -> %d\n", sn, sn_attri[sn].stat, stat);
                        sn_attri[sn].stat = stat;
                        memset(msg_buf, 0, MSG_SIZE);
                        sprintf(msg_buf, "%s: %s", sn_attri[0].nickname, "#0 your connection terminated!");
                        ret = write(fd[sn][1], msg_buf, MSG_SIZE); /* non-blocking write ord-pipe */
                        if (ret <= 0)
                        {
                            printf("sn = %d write error, message missed ...\n", sn);
                        };
                    }
                    else
                    {
                        flags = fcntl(fd[sn][1], F_GETFL, 0);
                        fcntl(fd[sn][1], F_SETFL, flags | O_NONBLOCK); /* set to non-blocking write ord-pipe */
                        memset(msg_buf, 0, MSG_SIZE);
                        sprintf(msg_buf, "%s: %s", sn_attri[0].nickname, &stdin_buf[i]);
                        ret = write(fd[sn][1], msg_buf, MSG_SIZE); /* non-blocking write ord-pipe */
                        if (ret <= 0)
                        {
                            printf("sn = %d write error, message missed ...\n", sn);
                        }
                    }
                }; /* invalid connect_sn ignored */
            }
            else if (stdin_buf[0] == '#')
            { /* #: listing all connectors of the BBS */
                printf("\n====   connector list   =====\n");
                for (i = 0; i <= max_sn; i++)
                { /* sn_attri[0].nickname = "Console" */
                    printf("sn = %d, stat = %s, nickname = %s\n", i, stat_descriptor(sn_attri[i].stat, stat_str), sn_attri[i].nickname);
                }
                printf("\n");
            }
            else
            {
                memset(msg_buf, 0, MSG_SIZE);
                sprintf(msg_buf, "%s: %s", sn_attri[0].nickname, stdin_buf);
                for (sn = 1; sn <= max_sn; sn++)
                { /* message sent to all sn's by ord-pipes fd[sn][1] */
                    if (sn_attri[sn].stat == STAT_NORMAL)
                    {
                        flags = fcntl(fd[sn][1], F_GETFL, 0);
                        fcntl(fd[sn][1], F_SETFL, flags | O_NONBLOCK); /* set to non-blocking write ord-pipe */
                        ret = write(fd[sn][1], msg_buf, MSG_SIZE);     /* non-blocking write ord-pipe */
                        if (ret <= 0)
                        {
                            printf("sn = %d write error, message missed ...\n", sn);
                        }
                    }
                }
            }
        }
    }
    return;
}

void recv_send_data(int sn)
{
    char recv_buf[BUFFER_SIZE], send_buf[BUFFER_SIZE];
    char msg_buf[MSG_SIZE]; /* sn(4)nickname(10)recv_buff(BUFFER_SIZE) */
    int recvbytes, sendbytes, ret, flags;
    int stat;

    flags = fcntl(connect_fd[sn], F_GETFL, 0);
    fcntl(connect_fd[sn], F_SETFL, flags | O_NONBLOCK); /* set to non-blocking mode to socket recv */
    flags = fcntl(fd[sn][0], F_GETFL, 0);
    fcntl(fd[sn][0], F_SETFL, flags | O_NONBLOCK); /* set to non-blocking mode to ord-pipe read */

    while (1)
    {                                                                          /* receiving and sending cycle */
        recvbytes = recv(connect_fd[sn], recv_buf, BUFFER_SIZE, MSG_DONTWAIT); /* non-blocking socket recv */
        if (recvbytes > 0)
        {
            printf("===>>> SN-%d: %s\n", sn, recv_buf);
            memset(msg_buf, 0, MSG_SIZE);
            sprintf(msg_buf, "%4d%s", sn, recv_buf);
            ret = write(fd_msg[1], msg_buf, MSG_SIZE); /* blocking write ord-pipe to pipe_data() */
            if (ret <= 0)
            {
                perror("fd_stat write() to pipe_data()");
                break;
            }
        }
        ret = read(fd[sn][0], msg_buf, MSG_SIZE); /* non-blocking read ord-pipe from pipe_data() */
        if (ret > 0)
        {
            printf("sn = %d send_buf ready: %s\n", sn, msg_buf);
            sendbytes = send(connect_fd[sn], msg_buf, MSG_SIZE, 0); /* blocking socket send */
            if (sendbytes <= 0)
            {
                break;
            }
        }
        sleep_ms(1); /* heart beating */
    }
    return;
}

int main(int argc, char *argv[])
{
    socklen_t addr_len;
    pid_t pipe_pid, recv_pid, send_pid;
    char stdin_buf[BUFFER_SIZE], ip4_addr[INET_ADDRSTRLEN];
    uint16_t port_num;
    int ret;
    char fifoname[80], clr;
    int stat;

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
        {
            printf("new fifo %s named pipe created\n", fifoname);
        }
    }
    fdr = open(fifoname, O_RDWR); /* blocking write and blocking read in default */
    if (fdr < 0)
    {
        perror("named pipe read open()");
        exit(EXIT_FAILURE);
    }

    for (int i = 0; i <= MAX_CONN_NUM; i++)
    {
        ret = pipe(fd[i]);
        if (ret == -1)
        {
            perror("fd pipe()");
        }
    }

    ret = pipe(fd_stat);
    if (ret == -1)
    {
        perror("fd_stat pipe()");
    }

    ret = pipe(fd_msg);
    if (ret == -1)
    {
        perror("fd_msg pipe()");
    }

    for (int i = 0; i <= MAX_CONN_NUM; i++)
    {
        sn_attri[i].stat = STAT_EMPTY;
        strcpy(sn_attri[i].nickname, "Anonymous");
    }

    strcpy(sn_attri[0].nickname, "Console");

    server_fd = socket(AF_INET, SOCK_STREAM, 0);
    if (server_fd == -1)
    {
        ERR_EXIT("socket()");
    }
    printf("server_fd = %d\n", server_fd);

    getipv4addr(ip4_addr);

    printf("input server port number: ");
    memset(stdin_buf, 0, BUFFER_SIZE);
    fgets(stdin_buf, 6, stdin);
    stdin_buf[5] = 0;
    port_num = atoi(stdin_buf);

    /* set sockaddr_in */
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(port_num);
    //    server_addr.sin_addr.s_addr = INADDR_ANY;
    server_addr.sin_addr.s_addr = inet_addr(ip4_addr);
    bzero(&(server_addr.sin_zero), 8); /* padding with 0's */

    int opt_val = 1;
    setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR, &opt_val, sizeof(opt_val)); /* many options */

    addr_len = sizeof(struct sockaddr);
    ret = bind(server_fd, (struct sockaddr *)&server_addr, addr_len);
    if (ret == -1)
    {
        close(server_fd);
        ERR_EXIT("bind()");
    }
    printf("Bind success!\n");

    ret = listen(server_fd, MAX_QUE_CONN_NM);
    if (ret == -1)
    {
        close(server_fd);
        ERR_EXIT("listen()");
    }
    printf("Listening ...\n");

    pipe_pid = fork();
    if (pipe_pid < 0)
    {
        close(server_fd);
        ERR_EXIT("fork()");
    }
    if (pipe_pid == 0)
    {
        pipe_data();
        exit(EXIT_SUCCESS); /* ignoring all the next statements */
    }

    max_sn = 0;
    connect_sn = 1;
    while (1)
    {
        if (connect_sn > MAX_CONN_NUM)
        {
            printf("connect_sn = %d out of range\n", connect_sn);
            break;
        }
        addr_len = sizeof(struct sockaddr); /* should be assigned each time accept() called */
        connect_fd[connect_sn] = accept(server_fd, (struct sockaddr *)&connect_addr, &addr_len);
        if (connect_fd[connect_sn] == -1)
        {
            perror("accept()");
            continue;
        }
        port_num = ntohs(connect_addr.sin_port);
        strcpy(ip4_addr, inet_ntoa(connect_addr.sin_addr));
        printf("New connection sn = %d, fd = %d, IP_addr = %s, port = %hu\n", connect_sn, connect_fd[connect_sn], ip4_addr, port_num);

        stat = STAT_ACCEPTED;
        sprintf(stdin_buf, "%d,%d", connect_sn, stat);
        ret = write(fd_stat[1], stdin_buf, sizeof(stdin_buf)); /* blocking write ordinary pipe to pipe_data() */
        if (ret <= 0)
        {
            perror("fd_stat write() from recv_send_data() to pipe_data()");
        }

        sprintf(stdin_buf, "%s", "Console: Pls initiate you nickname by [#1nickname]");
        ret = send(connect_fd[connect_sn], stdin_buf, BUFFER_SIZE, 0); /* blocking socket send */
        if (ret <= 0)
        {
            perror("send()");
        }

        recv_pid = fork();
        if (recv_pid < 0)
        {
            perror("fork()");
            break;
        }
        if (recv_pid == 0)
        {
            recv_send_data(connect_sn);
            exit(EXIT_SUCCESS); /* ignoring all the next statements */
        }

        ret = max_sn = connect_sn;
        write(fd[0][1], &max_sn, sizeof(max_sn)); /* blocking write ordinary pipe to pipe_data() */
        if (ret <= 0)
        {
            perror("fd_stat write() from recv_send_data() to pipe_data()");
        }
        connect_sn++;
        /* parent pro continue to listen to a new client forever */
    }

    wait(0);
    for (int sn = 1; sn <= max_sn; sn++)
    {
        close(connect_fd[sn]);
    }
    close(server_fd);
    exit(EXIT_SUCCESS);
}
