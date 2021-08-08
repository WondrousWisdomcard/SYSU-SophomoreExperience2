#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/stat.h>
#include <string.h>
#include <sys/shm.h>

#include "alg.8-0-shmdata.h"

int main(int argc, char *argv[])
{
    void *shmptr = NULL;
    struct shared_struct *shared;
    int shmid;
    key_t key;
 
    sscanf(argv[1], "%x", &key);
    printf("%*sshmread: IPC key = %x\n", 30, " ", key);
    
    shmid = shmget((key_t)key, TEXT_NUM*sizeof(struct shared_struct), 0666|PERM);
    if (shmid == -1) {
        ERR_EXIT("shread: shmget()");
    }

    shmptr = shmat(shmid, 0, 0);
    if(shmptr == (void *)-1) {
        ERR_EXIT("shread: shmat()");
    }
    printf("%*sshmread: shmid = %d\n", 30, " ", shmid);    
    printf("%*sshmread: shared memory attached at %p\n", 30, " ", shmptr);
    printf("%*sshmread process ready ...\n", 30, " ");
    
    shared = (struct shared_struct *)shmptr;
    
    while (1) {
        while (shared->written == 0) {
            sleep(1); /* message not ready, waiting ... */
        }
        printf("%*sYou wrote: %s\n", 30, " ", shared->mtext);
        shared->written = 0;
        if (strncmp(shared->mtext, "end", 3) == 0) {
            break;
        }
    } /* it is not reliable to use shared->written for process synchronization */
     
   if (shmdt(shmptr) == -1) {
        ERR_EXIT("shmread: shmdt()");
   }
 
    sleep(1);
    exit(EXIT_SUCCESS);
}
