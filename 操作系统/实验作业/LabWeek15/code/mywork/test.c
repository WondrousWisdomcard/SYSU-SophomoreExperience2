#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>
#include <assert.h>
#include <signal.h>
#include <errno.h>
#include "thread_pool.h"

# define T_NUM 20

int n = T_NUM;

void* func1(void *arg){
	int m = *(int *)arg;
    printf("Thread-%02ld start TASK-%03d\n",pthread_self()%100,m);
    sleep(m % 3 + 1);
    printf("\t\t\tThread-%02ld finish TASK-%03d\n",pthread_self()%100,m);
    return NULL;
}

int main(int argc, char* argvs[]){
	if(argc == 2){
		n = atoi(argvs[1]); 
		if(n <= 0){
			printf("Inproper input!\n");
			return 1;
		}
	}
	
	thread_pool* tp = thread_pool_create(2, 16, 10);	
    if(tp == NULL){
    	printf("main(): Error in thread_pool_create()\n");
    }
    
    thread_pool_show(tp);
    
    int a[n];
    int i, ret;
    for(i = 0; i < n; i++)
    {
        a[i] = i;
        ret = task_create(tp, a[i], func1, (void*)(a + i));
        if(ret == -1){
    		printf("main(): Error in task_create()\n");
    	}
    }
    
    thread_pool_wait(tp);    
    thread_pool_show(tp);    
    thread_pool_destory(tp);
    return 0;
}
