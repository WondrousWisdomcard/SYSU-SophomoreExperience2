#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <pthread.h>

static void *ftn(void *arg)
{
    int *numptr = (int *)arg;
    int num = *numptr;

    char *retval = (char *)malloc(80*sizeof(char));  /* allocated in the process heap */
  
    sprintf(retval, "This is thread-%d, ptid = %lu", num, pthread_self( ));
    printf("%s\n", retval);

    pthread_exit((void *)retval); /* or return (void *)retval; */
}
 
int main(int argc, char *argv[])
{
    int max_num = 5;
    int i, ret;

    printf("Usage: ./a.out total_thread_num\n");
    if(argc > 1) {
        max_num = atoi(argv[1]);
    }

    int thread_num[max_num];
    for (i = 0; i < max_num; i++) {
        thread_num[i] = i;
    }

    printf("main(): pid = %d, ptid = %lu.\n", getpid( ), pthread_self( ));
    
    pthread_t ptid[max_num];
    for (i = 0; i < max_num; i++) {
        ret = pthread_create(&ptid[i], NULL, ftn, (void *)&thread_num[i]);
        if(ret != 0) {
            fprintf(stderr, "pthread_create error: %s\n", strerror(ret));
            exit(1);
        }
    }

    for (i = 0; i < max_num; i++) {
        char *retptr;  /* retptr pointing to address allocated by ftn() */
        ret = pthread_join(ptid[i], (void **)&retptr);
        if(ret!=0) {
            fprintf(stderr, "pthread_join error: %s\n", strerror(ret));
            exit(1);
        }
        printf("thread-%d: retval = %s\n", i, retptr);
        free(retptr);
        retptr = NULL;  /* preventing ghost pointer */
    }

    return 0;
}


