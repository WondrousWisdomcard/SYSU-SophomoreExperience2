/* gcc -lpthread | -pthread */
/* without global variable sum defined */

#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

static void *runner(void *); /* thread function */

int main(void)
{
    int sum, ret; /* sum in main-thread stack */
    int *retptr = &sum;

    pthread_t ptid;
    pthread_attr_t attr; /* thread attributes structure */
    pthread_attr_init(&attr); /* set the default attributes */
      /* create the thread - runner with &sum */
    ret = pthread_create(&ptid, &attr, &runner, &sum);
    if(ret != 0) {
        perror("pthread_create()");
        return 1;
    }

    ret = pthread_join(ptid, (void **)&retptr);
    if(ret != 0) {
        perror("pthread_join()");
        return 1;
    }

    printf("sum = %d\n", sum);
    printf("sum = %d\n", *retptr);
	
    return 0;
}

  /* The thread will begin control in this function */
static void *runner(void *param)
{
    int *sum = (int *)param;
    int upper = 10;
    int i;

    *sum = 0;
    for (i = 1; i <= upper; i++)
        *sum += i;

    pthread_exit((void *)sum); /* return the address in process stack segment */
    /* also: return (void *)sum; */
}

