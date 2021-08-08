#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/msg.h>
#include <sys/stat.h>
#include <fcntl.h>
 
#include "alg.9-0-msgdata.h"

int main(int argc, char *argv[])
{
    char pathname[80];
    struct stat fileattr;
    key_t key;
    struct msg_struct data;
    long int msg_type;
    char buffer[TEXT_SIZE];
    int msqid, ret, count = 0;
    FILE *fp;

    if(argc < 2) {
        printf("Usage: ./a.out pathname\n");
        return EXIT_FAILURE;
    }
    strcpy(pathname, argv[1]);

    if(stat(pathname, &fileattr) == -1) {
        ret = creat(pathname, O_RDWR);
        if (ret == -1) {
            ERR_EXIT("creat()");
        }
        printf("shared file object created\n");
    }
    
    key = ftok(pathname, 0x27); /* project_id can be any nonzero integer */
    if(key < 0) {
        ERR_EXIT("ftok()");
    }
	
    printf("\nIPC key = 0x%x\n", key);	
    
    msqid = msgget((key_t)key, 0666 | IPC_CREAT);
    if(msqid == -1) {
        ERR_EXIT("msgget()");
    }
 
    fp = fopen("./alg.9-0-msgsnd.txt", "rb");
    if(!fp) {
        ERR_EXIT("source data file: ./msgsnd.txt fopen()");
    }

    struct msqid_ds msqattr;
    ret = msgctl(msqid, IPC_STAT, &msqattr);
    printf("number of messages remainded = %ld, empty slots = %ld\n", msqattr.msg_qnum, 16384/TEXT_SIZE-msqattr.msg_qnum);
    printf("Blocking Sending ... \n");
    while (!feof(fp)) {
        ret = fscanf(fp, "%ld %s", &msg_type, buffer);
        if(ret == EOF) {
            break;
        }
        printf("%ld %s\n", msg_type, buffer);
                        
        data.msg_type = msg_type;
        strcpy(data.mtext, buffer);

        ret = msgsnd(msqid, (void *)&data, TEXT_SIZE, 0); /* 0: blocking send, waiting when msg queue is full */
        if(ret == -1) {
            ERR_EXIT("msgsnd()");
        }
        count++;
    }

    printf("number of sent messages = %d\n", count);

    fclose(fp);
    system("ipcs -q");
    exit(EXIT_SUCCESS);
}
