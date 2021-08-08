#include <stdio.h> 
#include <stdlib.h>
#include <malloc.h>
#include <unistd.h>
#include <pthread.h> 

#define STACK_SIZE (524288-10000)*4096 /* 2^19 = 524288, STACK_SIZE is nearly 2G */

static void *test(void *arg)
{ 
    static int i =0;
    char buffer[1024]; /* 1KiB saved to the thread stack */

    if(i > 5 && i < 1965030)
        printf("\b\b\b\b\b\b\b\b%8d", i); 
    else
        printf("\niteration = %8d", i);
    i++; 
    test(arg); /* recursive calling until segmentation fault */ 
} 

int main(void)
{ 
    int ret;
    pthread_t ptid;
    pthread_attr_t tattr;

    char *stackptr = malloc(STACK_SIZE);
    if(!stackptr) {
        perror("malloc()");
        return EXIT_FAILURE;
    }

    pthread_attr_init(&tattr); 
    pthread_attr_setstack(&tattr, stackptr, STACK_SIZE); 
    ret = pthread_create(&ptid, &tattr, &test, NULL); 
    if(ret) {
        perror("pthread_create()");
        return EXIT_FAILURE;
    }

    pthread_join(ptid, NULL); 
    
    free(stackptr);
    stackptr = NULL;
    
    return EXIT_SUCCESS;
} 

