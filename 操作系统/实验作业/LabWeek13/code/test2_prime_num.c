#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <sys/time.h>
#include <unistd.h>

#include "thread_pool.h"
#define PNUM 16
// 计算 n 内质数的个数

int n = 10000;

static void *runner(void *par){
	//sleep(1);
	int * a = (int *)par;
	int m = a[0];
	int i,j = 0;
	//printf("Thread: %2d Tid: %lu\n", m, pthread_self());
	//printf("%2d\n",a[0]);
	for(i = m; i <= n; i += (PNUM+1)){
		if(i < 2){
			i += (PNUM+1);
		}
		else if(i > n){
			break;
		}
		
		for(j = 2; j < i; j++){
			if(i % j == 0){
				break;
			}
		}
		if (j == i){
			a[1]++;
			//printf("Thread %2d : %2d is a prime numer\n",m,i);
		} 
	}
	pthread_exit(0);
}

void without_thread(){
	int ans = 0,i,j;
	long ts = 0, te = 0;
	struct timeval t; 
	
	gettimeofday(&t, 0);
	ts = (long) t.tv_sec*1000*1000 + t.tv_usec;
	
	for(i = 3; i <= n; i += 2){
		for(j = 2; j < i; j++){
			if(i % j == 0){
				break;
			}
		}
		if (j == i){
			ans ++;
		} 
	}
	ans++;
	gettimeofday(&t, 0);
	te = (long) t.tv_sec*1000*1000 + t.tv_usec;
	printf("Then we don't use multi-threads to compute, cost %ld us\n", te-ts);
	printf("And The result is %2d\n",ans);
	
}

void use_thread_pool(){
	int args[PNUM][2];
	for(int i = 0; i < PNUM; i++){
		args[i][0] = i+1; //mod num
		args[i][1] = 0; //ans
	}
		
	long ts = 0, te = 0;
	struct timeval t; 
	
	gettimeofday(&t, 0);
	ts = (long) t.tv_sec*1000*1000 + t.tv_usec;
	
	thread_pool* tp = thread_pool_create(6, 30, 10);
	if(tp == NULL){
    	printf("main(): Error in thread_pool_create()\n");
    }
    
    int a[PNUM];
    int i, ret;
    for(i = 0; i < PNUM; i++)
    {
        a[i] = i;
        ret = task_create(tp, a[i], runner, (void *)&args[i]);
        if(ret == -1){
    		printf("main(): Error in task_create()\n");
    	}
    }

    thread_pool_wait(tp);
    
    thread_pool_destory(tp);
    
    int ans = 0;
	for(int i = 0; i < PNUM; i++){
		printf("In thread pool, Task %2d calculated %2d prime number\n", i ,args[i][1]);
		ans += args[i][1];
	}
	ans++;
	
	gettimeofday(&t, 0);
	te = (long) t.tv_sec*1000*1000 + t.tv_usec;
	
	printf("The result is %2d\n",ans);
	
	printf("We use thread pool to compute, cost %ld us\n", te-ts);
}

void use_pthread(){
	long ts = 0, te = 0;
	struct timeval t; 
	
	gettimeofday(&t, 0);
	ts = (long) t.tv_sec*1000*1000 + t.tv_usec;
	
	int args[PNUM][2];
	for(int i = 0; i < PNUM; i++){
		args[i][0] = i+1; //mod num
		args[i][1] = 0; //ans
	}
		
	pthread_t ptid[PNUM];
	pthread_attr_t attr[PNUM];
	for(int i = 0; i < PNUM; i++){
		pthread_attr_init(attr+i);
	}
	for(int i = 0; i < PNUM; i++){
		int ret = pthread_create(ptid+i,attr+i,&runner,(void *)&args[i]);
		if(ret == -1){
			perror("pthread_create()");
			return;
		}
	}
	for(int i = 0; i < PNUM; i++){
		int ret = pthread_join(ptid[i], NULL);
		if(ret == -1){
			perror("pthread_create()");
			return;
		}
	}
	int ans = 0;
	for(int i = 0; i < PNUM; i++){
		printf("Pthread %2d calculated %2d prime number\n", i ,args[i][1]);
		ans += args[i][1];
	}
	ans++;
	
	gettimeofday(&t, 0);
	te = (long) t.tv_sec*1000*1000 + t.tv_usec;
	
	printf("The result is %2d\n",ans);
	printf("We use %2d threads to compute, cost %ld us\n", PNUM, te-ts);
}

int main(int argc, char* argvs[]){
	if(argc == 2){
		n = atoi(argvs[1]); 
		if(n <= 2){
			printf("Inproper input!\n");
			return 1;
		}
	}
	printf("Let find the prime number num from 2 to %2d\n",n);
	
	printf("--------------------------------------\n");
	//use pthread
	use_pthread();
	printf("--------------------------------------\n");
	//use thread pool
	use_thread_pool();
	printf("--------------------------------------\n");
	//without_thread
	without_thread();
	printf("--------------------------------------\n");
	return 0;
	
}
