#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <pthread.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <semaphore.h>

#include "scheduler.h"

struct scheduler sche;

static void *runner(void *par){
	
	struct ctl_node * cn = (struct ctl_node *)par; // [0]
	
	sem_wait(&(cn->start_sem)); // [1]
	
	printf("Thread %d will work %d second(s)\n",cn->id, cn->worst_time);
	sleep(cn->worst_time);
	scheduler_show(&sche);
	
	sem_post(&(cn->finish_sem)); // [2]
	pthread_exit(0);
}

int main(){
	int pnum = 10;
	
	printf("------------SJB TEST INPUT------------\n");
	printf("enter the args of sjb-test\n");
	printf("NOTICE: start time must be incremental\n");	
	printf("thread num: ");
	scanf("%d",&pnum);
	if(pnum <= 0){
		printf("sjb_test(): invalid thread num\n");
		return 1;
	}
	int run_t[pnum],start_t[pnum];
	for(int i = 0; i < pnum; i++){
		printf("start time (sec) of thread-%d: ", i+1);
		scanf("%d",start_t+i);
		if(start_t[i] < 0){
			printf("sjb_test(): invalid start time\n");
			return 1;
		}
	}
	for(int i = 0; i < pnum; i++){
		printf("run time (sec) of thread-%d: ", i+1);
		scanf("%d",run_t+i);	
		if(run_t[i] < 0){
			printf("sjb_test(): invalid run time\n");
			return 1;
		}
	}
	printf("---------------------------------------\n\n");
	
	scheduler_init(&sche); // [3]
	pthread_t scheduler_thread;
	pthread_attr_t st;
	
	int ret = pthread_attr_init(&st);  // [4]
	if(ret == -1){
		perror("pthread_attr_init()");
	}
	pthread_create(&scheduler_thread, &st, &scheduler_np, (void *)(&sche)); 
	if(ret == -1){
		perror("pthread_create()");
	}
	
	
	pthread_t t[pnum];
	pthread_attr_t at[pnum];
	
	for(int i = 0; i < pnum; i++){
		pthread_attr_init(at+i);
		if(i == 0)
			sleep(start_t[i]);
		else
			sleep(start_t[i] - start_t[i-1]);
		
		ctl_node* cn = ctl_node_create(i+1, run_t[i], 0); // [5]
		enqueue(&sche, cn, SJB); // [5]
		
		pthread_create(t+i, at+i, &runner, (void *)(cn));
		
		if(ret == -1){
			perror("pthread_create()");
		}
	}
	for(int i = 0; i < pnum; i++){
		pthread_join(t[i], NULL);
		if(ret == -1){
			perror("pthread_join()");
		}
		
	}
	pthread_join(scheduler_thread, NULL);
	return 0;	
}
