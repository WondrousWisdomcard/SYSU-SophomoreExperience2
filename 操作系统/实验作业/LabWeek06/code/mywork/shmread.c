#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/stat.h>
#include <string.h>
#include <sys/shm.h>

#include "shmdata.h"

int main(int argc, char *argv[])
{
    void *shmptr = NULL;
    struct shared_struct *shared;
    int shmid;
    key_t key;
 
    sscanf(argv[1], "%x", &key);
    printf("%*sshmread: IPC key = %x\n", 30, " ", key);
    
    shmid = shmget((key_t)key, sizeof(struct shared_struct), 0666|PERM);
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
    sleep(1);

    while (1) {
    	
        while (shared->mode == WRITE) {
            sleep(1); 
        } // write mode the sleep
        
        if(shared->head == shared->tail) { // detected the queue is empty then turn to write mode or end this process
            if(shared->mode == READ){ // turn to write mode         
                printf("[read] finish reading, turn to write\n\n");
                shared->mode = WRITE;
            }
            else if(shared->mode == READEND){ // end the process
            	printf("[read] finish reading, end this process\n\n");
            	break;
            }
        }
        else{ //normally print the student's information
            printf("[read] Student %s's id is %d\n", shared->cell[shared->tail].name, shared->cell[shared->tail].id);
            (shared->tail) += 1;
            (shared->tail) %= (TEXT_NUM + 1);
        }
        
    }   

    sleep(1);
    exit(EXIT_SUCCESS);
}
