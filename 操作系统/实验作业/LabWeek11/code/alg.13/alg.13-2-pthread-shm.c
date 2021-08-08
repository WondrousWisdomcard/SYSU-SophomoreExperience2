/*  gcc -lpthread | -pthread */
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <pthread.h>

#define MSG_SIZE 1024

struct msg_stru {
    char msg1[MSG_SIZE], msg2[MSG_SIZE], msg3[MSG_SIZE];
}; /* global variable */

static void *runner1(void *);
static void *runner2(void *);

int main(void)
{
    pthread_t tid1, tid2;
    pthread_attr_t attr = {0};

    struct msg_stru msg; /* storage in main-thread stack */
	
    sprintf(msg.msg1, "message 1 by parent");
    sprintf(msg.msg2, "message 2 by parent");
    sprintf(msg.msg3, "message 3 by parent");
    printf("\nparent say:\n%s\n%s\n%s\n", msg.msg1, msg.msg2, msg.msg3);
	
    pthread_attr_init(&attr);

    if(pthread_create(&tid1, &attr, &runner1, (void *)&msg) != 0) {
        perror("pthread_create()");
        return 1;
    }
    if(pthread_create(&tid2, &attr, &runner2, (void *)&msg) != 0) {
        perror("pthread_create()");
        return 1;
    }
   
    if(pthread_join(tid1, NULL) != 0) {
        perror("pthread_join()");
        return 1;
    }

    if(pthread_join(tid2, NULL) != 0) {
        perror("pthread_join()");
        return 1;
    }

    printf("\nparent say:\n%s\n%s\n%s\n", msg.msg1, msg.msg2, msg.msg3);

    return 0;
}

static void *runner1(void *param)
{
    struct msg_stru *ptr = (struct msg_stru *)param;
    sprintf(ptr->msg1, "message 1 changed by child1");
    pthread_exit(0);
}

static void *runner2(void *param)
{
    struct msg_stru *ptr = (struct msg_stru *)param;
    sprintf(ptr->msg2, "message 2 changed by child2");
    pthread_exit(0);
}

