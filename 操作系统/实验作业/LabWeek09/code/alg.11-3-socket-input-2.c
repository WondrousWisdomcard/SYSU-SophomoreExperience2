#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>

#define BUFFER_SIZE 1024

/* input terminal, data packed without '\n' */
/* write to pipe_data() through a named pipe */
int main(int argc, char *argv[])
{
    char fifoname[80], write_buf[BUFFER_SIZE];
    int fdw, flags, ret, i;

    if (argc < 2)
    {
        printf("Usage: ./a.out pathname\n");
        return EXIT_FAILURE;
    }
    strcpy(fifoname, argv[1]);
    if (access(fifoname, F_OK) == -1)
    {
        if (mkfifo(fifoname, 0666) != 0)
        { /* make a named pipe */
            perror("mkfifo()");
            exit(EXIT_FAILURE);
        }
        else
            printf("new fifo %s created ...\n", fifoname);
    }

    fdw = open(fifoname, O_RDWR); /* blocking write and blocking read in default */

    if (fdw < 0)
    {
        perror("pipe open()");
        exit(EXIT_FAILURE);
    }
    else
    {
        flags = fcntl(fdw, F_GETFL, 0);
        fcntl(fdw, F_SETFL, flags | O_NONBLOCK); /* set to non-blocking write named pipe */
        while (1)
        {
            printf("Enter some text (#0-quit | #1-nickname): \n");
            memset(write_buf, 0, BUFFER_SIZE);
            fgets(write_buf, BUFFER_SIZE, stdin);
            write_buf[BUFFER_SIZE - 1] = 0;
            for (i = 0; i < BUFFER_SIZE; i++)
            {
                if (write_buf[i] == '\n')
                {
                    write_buf[i] = 0;
                }
            }                                         /* '\n' filtered */
            if(strlen(write_buf) == 0){
            	continue;
            }
            ret = write(fdw, write_buf, BUFFER_SIZE); /* non-blocking write named pipe */
            if (ret <= 0)
            {
                perror("write()");
                printf("Pipe blocked, try again ...\n");
                sleep(1);
            }
            if(strcmp(write_buf,"#0") == 0){
            	break;
            }
        }
    } 

    close(fdw);

    exit(EXIT_SUCCESS);
}
