/* gcc -lrt */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <mqueue.h>

#include "pmsgdata.h"

int main(int argc, char *argv[])
{
    char pathname[80], cmd_str[80];
    struct stat fileattr;
    int shmsize, ret;
    mqd_t mqID;
    pid_t childpid1, childpid2;
    
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
        printf("pmsgcon: Shared file object created\n");
    }
    
    mqID = mq_open(pathname, O_RDWR | O_CREAT , 0666, NULL);  // ./ filename as the shared object, creating if not exist
    if(mqID == -1) {
        ERR_EXIT("pmsgcon: mq_open()");
    } 
    
    
    char *argv1[] = {" ", argv[1], 0};
    childpid1 = vfork();
    if(childpid1 < 0) {
        ERR_EXIT("pmsgcon: 1st vfork()");
    } 
    else if(childpid1 == 0) {
        execv("./pmsgsnd.o", argv1); // call pmsgsnd with filename 
    }
    else {
        childpid2 = vfork();
        if(childpid2 < 0) {
            ERR_EXIT("pmsgcon: 2nd vfork()");
        }
        else if (childpid2 == 0) {
        	//sleep(2);
            execv("./pmsgrcv.o", argv1); // call pmsgrcv with filename
        }
        else {
            wait(&childpid1);
            wait(&childpid2);
        }
    }
    exit(EXIT_SUCCESS);
}

