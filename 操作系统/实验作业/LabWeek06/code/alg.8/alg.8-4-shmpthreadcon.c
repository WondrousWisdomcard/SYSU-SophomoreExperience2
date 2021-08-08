/* gcc -lrt */
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <fcntl.h>
#include <sys/mman.h>

#include "alg.8-0-shmdata.h"

int main(int argc, char *argv[])
{
    char pathname[80], cmd_str[80];
    struct stat fileattr;
    int fd, shmsize, ret;
    pid_t childpid1, childpid2;

    if(argc < 2) {
        printf("Usage: ./a.out filename\n");
        return EXIT_FAILURE;
    }

    fd = shm_open(argv[1], O_CREAT|O_RDWR, 0666); 
        /* /dev/shm/filename as the shared object, creating if not exist */
    if(fd == -1) {
        ERR_EXIT("con: shm_open()");
    } 
    system("ls -l /dev/shm/");   
 
    /* set shared size to 1.8GB; near the upper bound of 90% phisical memory size of 2G
       shmsize = 1.8*1024*1024*1024; */

    shmsize = TEXT_NUM*sizeof(struct shared_struct);
    ret = ftruncate(fd, shmsize);
    if(ret == -1) {
        ERR_EXIT("con: ftruncate()");
    }
    
    char *argv1[] = {" ", argv[1], 0};
    childpid1 = vfork();
    if(childpid1 < 0) {
        ERR_EXIT("shmpthreadcon: 1st vfork()");
    } 
    else if(childpid1 == 0) {
        execv("./alg.8-5-shmproducer.o", argv1); /* call shmproducer with filename */
    }
    else {
        childpid2 = vfork();
        if(childpid2 < 0) {
            ERR_EXIT("shmpthreadcon: 2nd vfork()");
        }
        else if (childpid2 == 0) {
            execv("./alg.8-6-shmconsumer.o", argv1); /* call shmconsumer with filename */
        }
        else {
            wait(&childpid1);
            wait(&childpid2);
            ret = shm_unlink(argv[1]); /* shared object can be removed by any process knew the filename */
            if(ret == -1) {
                ERR_EXIT("con: shm_unlink()");
            }
            system("ls -l /dev/shm/");   
        }
    }
    exit(EXIT_SUCCESS);
}

