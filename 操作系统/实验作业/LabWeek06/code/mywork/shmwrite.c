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
    struct shared_struct *shared = NULL;
    int shmid;
    key_t key;

    char buffer[BUFSIZ + 1]; /* 8192bytes, saved from stdin */
    
    sscanf(argv[1], "%x", &key);

    printf("shmwrite: IPC key = %x\n", key);

    shmid = shmget((key_t)key, sizeof(struct shared_struct), 0666|PERM);
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
    
    sleep(1);
    
    while (1) {
    
    	if((shared->head + 1) % (TEXT_NUM + 1) == shared->tail % (TEXT_NUM + 1)){
    	    printf("[write] the queue is full, automatically turn to read\n\n");
	    shared->mode = READ;
    	} // detect if queue is full then turn to read mode
    
        while (shared->mode == READ) {
            sleep(1); // read mode
        }
        
        printf("[write] enter student's id (-1 to turn, -2 to end): ");
        int sign;
        
        scanf("%d",&sign); 
        // -1 change mode
        // -2 to end process
        
        if(sign == -1){ //read mode transition
	    printf("[write] finish writing, turn to read\n\n");
	    shared->mode = READ;
        }
        else if(sign == -2){ // read-end mode transtion 
            printf("[write] finish writing, turn to read and end this process\n\n");
	    shared->mode = READEND;
	    break;
        }
        else{ // write information into shared memory queue
	    shared->cell[shared->head].id = sign;
	    printf("[write] enter student's name: ");
	    scanf("%s",(shared->cell[shared->head].name));

	    (shared->head) += 1; 
	    (shared->head) %= (TEXT_NUM + 1); //update the head index of queue
        }
        
    }
       /* detach the shared memory */
    if(shmdt(shmptr) == -1) {
        ERR_EXIT("shmwrite: shmdt()");
    }

//    sleep(1);
    exit(EXIT_SUCCESS);
}
