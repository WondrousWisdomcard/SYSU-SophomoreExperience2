/* gcc -lpthread | -pthread */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>

int sum; /* shared by thread(s) */

static void *runner(void *); /* thread function */

int main(int argc, char *argv[])
{
    char *retptr;
    int ret;

    if(argc < 2) {
        printf("usage: ./a.out <positive integer value>\n");
        return -1;
    }
    
    pthread_t ptid; /* thread identifier */
    pthread_attr_t attr; /* thread attributes structure */
    pthread_attr_init(&attr); /* set the default attributes */

      /* create the thread - runner with argv[1] */
    ret = pthread_create(&ptid, &attr, &runner, argv[1]);
    if(ret != 0) {
        perror("pthread_create()");
        return 1;
    }

    ret = pthread_join(ptid, (void **)&retptr);
    if(ret != 0) {
        perror("pthread_join()");
        return 1;
    }

    printf("return val = %s\n", retptr);
    printf("sum = %d\n", sum);
	
	free(retptr);
	retptr = NULL;
	
    return 0;
}

  /* The thread will begin control in this function */
static void *runner(void *param)
{
    int i = 1;
    int upper = atoi(param);

    sum = 0;
    for (; i <= upper; i++)
        sum += i;

    char msg[] = "Hello, world!";
    char *retptr = (char *)malloc((strlen(msg)+1)*sizeof(char)); /* allocated in process space */
    strcpy(retptr, msg);

    pthread_exit((void *)retptr);
}


