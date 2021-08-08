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
    struct shared_struct *shared = NULL;
    int shmid;
    key_t key;

    char buffer[BUFSIZ + 1]; /* 8192bytes, saved from stdin */
    
    sscanf(argv[1], "%x", &key);

    printf("shmwrite: IPC key = %x\n", key);

    shmid = shmget((key_t)key, TEXT_NUM*sizeof(struct shared_struct), 0666|PERM);
    if (shmid == -1) {
        ERR_EXIT("shmwite: shmget()");
    }

    shmptr = shmat(shmid, 0, 0);
    if(shmptr == (void *)-1) {
        ERR_EXIT("shmwrite: shmat()");
    }
    printf("shmwrite: shmid = %d\n", shmid);
    printf("shmwrite: shared memory attached at %p\n", shmptr);
    printf("shmwrite precess ready ...\n");
    
    shared = (struct shared_struct *)shmptr;
    
    while (1) {
        while (shared->written == 1) {
            sleep(1); /* message not read yet, waiting ... */ 
        }
 
        printf("Enter some text: ");
        fgets(buffer, BUFSIZ, stdin);
        strncpy(shared->mtext, buffer, TEXT_SIZE);
        printf("shared buffer: %s\n",shared->mtext);
        shared->written = 1;  /* message prepared */
 
        if(strncmp(buffer, "end", 3) == 0) {
            break;
        }
    }
       /* detach the shared memory */
    if(shmdt(shmptr) == -1) {
        ERR_EXIT("shmwrite: shmdt()");
    }

//    sleep(1);
    exit(EXIT_SUCCESS);
}
