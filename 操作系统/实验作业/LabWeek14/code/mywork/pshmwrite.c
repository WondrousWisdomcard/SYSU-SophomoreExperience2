#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/stat.h>
#include <string.h>
#include <sys/shm.h>
#include <pthread.h>
#include <signal.h>

#include "pshmdata.h"

struct shared_struct *shared;

static void *write_ftn(void *arg)
{
    int *numptr = (int *)arg;
    int thread_num = *numptr;
    int lev, k, j;
  	char buffer[TEXT_SIZE + 1];
  	
  	int pnum = shared->pnum_r + shared->pnum_w;
  	int base = shared->pnum_r;
  	
    //printf("write-thread-%d, ptid = %lu working\n", thread_num, pthread_self( ));
    //printf("write-thread-%d working\n", thread_num);
        
    // peterson    
    for (lev = 0; lev < pnum-1; ++lev) { // pnum-1 waiting rooms
        shared->level[thread_num + base] = lev;
        shared->waiting[lev] = thread_num + base;
        while (shared->waiting[lev] == thread_num + base) { // busy waiting
            for (k = 0; k < pnum; k++) {
                if(shared->level[k] >= lev && k != thread_num + base) {
                    break;
                }
                if(shared->waiting[lev] != thread_num + base) { // check again
                    break;
                }
            } 
            if(k == pnum) {
                break;
            } 
        }
    }  
    
    // ////// cs start 
    //printf("write-thread-%d, ptid = %lu entering the critical section\n", thread_num, pthread_self( ));
    printf("write-thread-%d entering the critical section\n", thread_num);
    
    // cs check
    shared->pnum_cs++;
    if (shared->pnum_cs > 1) {
        printf("ERROR! more than one processes in critical sections\n");
        kill(getpid(), SIGKILL);
    }
    shared->pnum_cs--;  
    
    // write mtext
    if(shared->last_read == -1 && shared->last_write != -1){
    	printf("No read-thread read mtext writtern by last write-thread-%d\n", shared->last_write);
    }
    printf("Enter some text: ");
    fgets(buffer, BUFSIZ, stdin);
    strncpy(shared->mtext, buffer, TEXT_SIZE);
    printf("Detected shared buffer: %s\n",shared->mtext);
    shared->last_read = -1;
    shared->last_write = thread_num;
    
        
    // ////// cs end
    
    // peterson
    shared->level[thread_num + base] = -1; 
    
    pthread_exit(0);
}


int main(int argc, char *argv[])
{
    void *shmptr = NULL;
    int shmid;
    key_t key;
	
    sscanf(argv[1], "%x", &key);
    printf("shmwrite: IPC key = %x\n", key);
    
    // shmget
    shmid = shmget((key_t)key, TEXT_NUM*sizeof(struct shared_struct), 0666|PERM);
    if (shmid == -1) {
        ERR_EXIT("shmwite: shmget()");
    }

	// shmat
    shmptr = shmat(shmid, 0, 0);
    if(shmptr == (void *)-1) {
        ERR_EXIT("shmwrite: shmat()");
    }
    printf("shmwrite: shmid = %d\n", shmid);
    printf("shmwrite: shared memory attached at %p\n", shmptr);
    
    shared = (struct shared_struct *)shmptr;
    
    
    // pthread_create
    int pnum_w = shared->pnum_w;
 	int i, ret;
    int thread_num[pnum_w];
    pthread_t ptid[pnum_w];
    
    printf("shmwrite: total read-thread number = %d\n", pnum_w);
    sleep(1);
    
    for (i = 0; i < pnum_w; i++) {
        thread_num[i] = i;
    }
    for (i = 0; i < pnum_w; i++) {
        ret = pthread_create(&ptid[i], NULL, &write_ftn, (void *)&thread_num[i]);
        if(ret != 0) {
            fprintf(stderr, "pthread_create error: %s\n", strerror(ret));
        }
    }

	// pthread_join
    for (i = 0; i < pnum_w; i++) {
        ret = pthread_join(ptid[i], NULL);
        if(ret != 0) {
           perror("pthread_join()");
        }
    }
    
    // shmdt
	if (shmdt(shmptr) == -1) {
		ERR_EXIT("shmread: shmdt()");
	}

	exit(EXIT_SUCCESS);
}

