#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <pthread.h>
#include <signal.h>

#define MAX_N 1024

static int counter = 0;
  /* number of process(s) in the critical section */
int level[MAX_N];
  /* level number of processes 0 .. MAX_N-1 */
int waiting[MAX_N-1];
  /* waiting process of each level number 0 .. MAX_N-2 */
int max_num = 20; /* default max thread number */

static void *ftn(void *arg)
{
    int *numptr = (int *)arg;
    int thread_num = *numptr;
    int lev, k, j;
  
    printf("thread-%3d, ptid = %lu working\n", thread_num, pthread_self( ));
        
    for (lev = 0; lev < max_num-1; ++lev) { /* there are at least max_num-1 waiting rooms */
        level[thread_num] = lev;
        waiting[lev] = thread_num;
        while (waiting[lev] == thread_num) { /* busy waiting */
            /*  && (there exists k != thread_num, such that level[k] >= lev)) */
            for (k = 0; k < max_num; k++) {
                if(level[k] >= lev && k != thread_num) {
                    break;
                }
                if(waiting[lev] != thread_num) { /* check again */
                    break;
                }
            } /* if any other proces j with level[j] < lev upgrades its level to or greater than lev during this period, then process thread_num must be kicked out the waiting room and waiting[lev] != thread_num, and then exits the while loop when scheduled */
            if(k == max_num) { /* all other processes have level of less than process thread_num */
                break;
            } 
        }
    }  
      /* critical section of process thread_num */
    printf("thread-%3d, ptid = %lu entering the critical section\n", thread_num, pthread_self( ));
    counter++;
    if (counter > 1) {
        printf("ERROR! more than one processes in their critical sections\n");
        kill(getpid(), SIGKILL);
    }
    counter--;  
      /* end of critical section */

    level[thread_num] = -1; 
      /* allow other process of level max_num-2 to exit the while loop 
         and enter his critical section */
    pthread_exit(0);
}
 
int main(int argc, char *argv[])
{
    printf("Usage: ./a.out total_thread_num\n");
    if(argc > 1) {
        max_num = atoi(argv[1]);
    }
    if (max_num < 0 || max_num > MAX_N) {
        printf("invalid max_num\n");
        exit(1);
    }

    memset(level, (-1), sizeof(level));
    memset(waiting, (-1), sizeof(waiting));

    int i, ret;
    int thread_num[max_num];
    pthread_t ptid[max_num];

    for (i = 0; i < max_num; i++) {
        thread_num[i] = i;
    }

    printf("total thread number = %d\n", max_num);
    printf("main(): pid = %d, ptid = %lu.\n", getpid( ), pthread_self( ));

    for (i = 0; i < max_num; i++) {
        ret = pthread_create(&ptid[i], NULL, &ftn, (void *)&thread_num[i]);
        if(ret != 0) {
            fprintf(stderr, "pthread_create error: %s\n", strerror(ret));
        }
    }

    for (i = 0; i < max_num; i++) {
        ret = pthread_join(ptid[i], NULL);
        if(ret != 0) {
           perror("pthread_join()");
        }
    }

    return 0;
}


