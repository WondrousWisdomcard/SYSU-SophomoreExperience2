#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <sys/shm.h>
#include <fcntl.h>

#include "alg.8-0-shmdata.h"

int main(int argc, char *argv[])
{
    struct stat fileattr;
    key_t key; /* of type int */
    int shmid; /* shared memory ID */
    void *shmptr;
    struct shared_struct *shared; /* structured shm */
    pid_t childpid1, childpid2;
    char pathname[80], key_str[10], cmd_str[80];
    int shmsize, ret;

    shmsize = TEXT_NUM*sizeof(struct shared_struct);
    printf("max record number = %d, shm size = %d\n", TEXT_NUM, shmsize);

    if(argc <2) {
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
 
    key = ftok(pathname, 0x27); /* 0x27 a project ID 0x0001 - 0xffff, 8 least bits used */
    if(key == -1) {
        ERR_EXIT("shmcon: ftok()");
    }
    printf("key generated: IPC key = %x\n", key); /* can set any nonzero key without ftok()*/

    shmid = shmget((key_t)key, shmsize, 0666|PERM);
    if(shmid == -1) {
        ERR_EXIT("shmcon: shmget()");
    }
    printf("shmcon: shmid = %d\n", shmid);

    shmptr = shmat(shmid, 0, 0); /* returns the virtual base address mapping to the shared memory, *shmaddr=0 decided by kernel */

    if(shmptr == (void *)-1) {
        ERR_EXIT("shmcon: shmat()");
    }
    printf("shmcon: shared Memory attached at %p\n", shmptr);
    
    shared = (struct shared_struct *)shmptr;
    shared->written = 0;

    sprintf(cmd_str, "ipcs -m | grep '%d'\n", shmid); 
    printf("\n------ Shared Memory Segments ------\n");
    system(cmd_str);
	
    if(shmdt(shmptr) == -1) {
        ERR_EXIT("shmcon: shmdt()");
    }

    printf("\n------ Shared Memory Segments ------\n");
    system(cmd_str);

    sprintf(key_str, "%x", key);
    char *argv1[] = {" ", key_str, 0};

    childpid1 = vfork();
    if(childpid1 < 0) {
        ERR_EXIT("shmcon: 1st vfork()");
    } 
    else if(childpid1 == 0) {
        execv("./alg.8-2-shmread.o", argv1); /* call shm_read with IPC key */
    }
    else {
        childpid2 = vfork();
        if(childpid2 < 0) {
            ERR_EXIT("shmcon: 2nd vfork()");
        }
        else if (childpid2 == 0) {
            execv("./alg.8-3-shmwrite.o", argv1); /* call shmwrite with IPC key */
        }
        else {
            wait(&childpid1);
            wait(&childpid2);
                 /* shmid can be removed by any process knewn the IPC key */
            if (shmctl(shmid, IPC_RMID, 0) == -1) {
                ERR_EXIT("shmcon: shmctl(IPC_RMID)");
            }
            else {
                printf("shmcon: shmid = %d removed \n", shmid);
                printf("\n------ Shared Memory Segments ------\n");
                system(cmd_str);
                printf("nothing found ...\n"); 
            }
        }
    }
    exit(EXIT_SUCCESS);
}

