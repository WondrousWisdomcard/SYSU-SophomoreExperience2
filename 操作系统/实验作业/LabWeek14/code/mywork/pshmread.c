#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/stat.h>
#include <string.h>
#include <sys/shm.h>
#include <pthread.h>
#include <signal.h>

#include "pshmdata.h"
#define SPACE 60
struct shared_struct *shared;

static void *read_ftn(void *arg)
{
    int *numptr = (int *)arg;
    int thread_num = *numptr;
    int lev, k, j;
  
  	int pnum = shared->pnum_r + shared->pnum_w;
  	int base = 0;
  	
    //printf("%*sread-thread-%d, ptid = %lu working\n", SPACE, " ", thread_num, pthread_self( ));
    //printf("%*sread-thread-%d working\n", SPACE, " ", thread_num);
        
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
    //printf("%*sread-thread-%d, ptid = %lu entering the critical section\n", SPACE, " " , thread_num, pthread_self( ));
    printf("%*sread-thread-%d entering the critical section\n", SPACE, " " , thread_num);
    
    // cs check
    shared->pnum_cs++;
    if (shared->pnum_cs > 1) {
        printf("ERROR! more than one processes in critical sections\n");
        kill(getpid(), SIGKILL);
    }
    shared->pnum_cs--;  
    
    // read mtext
	if(shared->last_write != -1){
    	printf("%*stext is writtern by write-thread-%d\n", SPACE, " " , shared->last_write);
    	if(shared->last_read != -1){
			printf("%*stext has already read by read-thread-%d\n", SPACE, " " , shared->last_read);
		} 
		printf("%*sread-thread-%d read: %s\n", SPACE, " " , thread_num, shared->mtext);
    } 
    else{
    	printf("%*sread-thread-%d read: [empty mtext]\n", SPACE, " ", thread_num);
    }
	shared->last_read = thread_num;
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
    printf("%*sshmread: IPC key = %x\n", SPACE, " ", key);
    
    // shmget
    shmid = shmget((key_t)key, TEXT_NUM*sizeof(struct shared_struct), 0666|PERM);
    if (shmid == -1) {
        ERR_EXIT("shread: shmget()");
    }

	// shmat
    shmptr = shmat(shmid, 0, 0);
    if(shmptr == (void *)-1) {
        ERR_EXIT("shread: shmat()");
    }
    
    printf("%*sshmread: shmid = %d\n", SPACE, " ", shmid);    
    printf("%*sshmread: shared memory attached at %p\n", SPACE, " ", shmptr);
    
    shared = (struct shared_struct *)shmptr;
    
    // pthread_create
    int pnum_r = shared->pnum_r;
    
    int i, ret;
    int thread_num[pnum_r];
    pthread_t ptid[pnum_r];

    printf("%*sshmread: total read-thread number = %d\n", SPACE, " ", pnum_r);
    sleep(1);
    for (i = 0; i < pnum_r; i++) {
        thread_num[i] = i;
    }
    for (i = 0; i < pnum_r; i++) {
        ret = pthread_create(&ptid[i], NULL, &read_ftn, (void *)&thread_num[i]);
        if(ret != 0) {
            fprintf(stderr, "pthread_create error: %s\n", strerror(ret));
        }
    }

	// pthread_join
    for (i = 0; i < pnum_r; i++) {
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
