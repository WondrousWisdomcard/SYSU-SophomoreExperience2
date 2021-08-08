#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <pthread.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <semaphore.h>
#include <string.h>
#include <signal.h>

#include "scheduler.h"

struct scheduler sche;

void interrupt_func(int signo){
	struct ctl_node* cn = sche.running_node;
	if(cn == NULL){
		return;
	}
	cn->re_sleep = 1;
	
	printf("Thread %d stop, turn to ready\n",cn->id);
	struct timeval t_now;
	gettimeofday(&t_now, 0);
	long run_time = gettime(cn->arrive_time, t_now);
	
	cn->rest_time = cn->worst_time - run_time/1000000;
	if(cn->rest_time <= 0){
		cn->rest_time = 0;
	}
	cn->state = READY;
	sem_post(&(cn->finish_sem));
}

static void *runner_p(void *par){
	
	struct ctl_node * cn = (struct ctl_node *)par;
	cn->ptid = pthread_self();
	
	struct sigaction act;
	memset (&act, '\0', sizeof(sigaction));
	act.sa_handler = interrupt_func; 
	act.sa_flags = 0; 

	int ret = sigaction(SIG, &act, NULL);
	if(ret == -1) {
		perror("signaction()");
		exit(EXIT_FAILURE);
	}
	
	do{
		// user area begin
		sem_wait(&(cn->start_sem));
		// do while no stable
		printf("Thread %d will work %d second(s)\n",cn->id, cn->rest_time);
		scheduler_show(&sche);
		sleep(cn->rest_time);
		
		// user area end
	}while(cn->re_sleep);
	
	sem_post(&(cn->finish_sem));
	pthread_exit(0);
}

int main(int argc, char* argvs[]){
	int tnum = 10;
	int mode = FCFS;
	
	if(argc == 2){
		if(argvs[1][0] == 'f' || argvs[1][0] == 'F'){
			mode = FCFS;
		}
		else if(argvs[1][0] == 's' || argvs[1][0] == 'S'){
			mode = SJF;
		}
		else if(argvs[1][0] == 'p' || argvs[1][0] == 'P'){
			mode = PRIO;
		}
	}	
	
	printf("-------Scheduler Preemptive Test-------\n");
	printf("scheduler mode: %s\n",argvs[1]);
	printf("enter the arguments\n");
	printf("thread num: ");
	scanf("%d",&tnum);
	if(tnum <= 0){
		printf("main(): invalid thread num\n");
		return 1;
	}
	
	int run_t[tnum], start_t[tnum], pri[tnum];
	for(int i = 0; i < tnum; i++){
		pri[i] = 0;
	}
	
	printf("NOTICE: start time must be incremental\n");	
	for(int i = 0; i < tnum; i++){
		printf("start time (sec) of thread-%d: ", i+1);
		scanf("%d",start_t+i);
		if(start_t[i] < 0){
			printf("main(): invalid start time\n");
			return 1;
		}
	}
	for(int i = 0; i < tnum; i++){
		printf("run time (sec) of thread-%d: ", i+1);
		scanf("%d",run_t+i);	
		if(run_t[i] < 0){
			printf("main(): invalid run time\n");
			return 1;
		}
	}
	if(mode == PRIO){
		for(int i = 0; i < tnum; i++){
			printf("priority of thread-%d: ", i+1);
			scanf("%d",pri+i);	
			if(pri[i] < 0){
				printf("prio_test(): invalid priority\n");
				return 1;
			}
		}
	}
	printf("---------------------------------------\n\n");

	scheduler_init(&sche, P);
	pthread_t scheduler_thread;
	pthread_attr_t st;
	
	int ret = pthread_attr_init(&st);
	if(ret == -1){
		perror("pthread_attr_init()");
	}
	pthread_create(&scheduler_thread, &st, &scheduler_p, (void *)(&sche)); 
	if(ret == -1){
		perror("pthread_create()");
	}
	
	
	pthread_t t[tnum];
	pthread_attr_t at[tnum];
	
	for(int i = 0; i < tnum; i++){
		pthread_attr_init(at+i);
		if(i == 0)
			sleep(start_t[i]);
		else
			sleep(start_t[i] - start_t[i-1]);
		
		ctl_node* cn = NULL;
		cn = ctl_node_create(i+1, run_t[i], pri[i]);
		enqueue(&sche, cn, mode);
		pthread_create(t+i, at+i, &runner_p, (void *)(cn));
		
		if(ret == -1){
			perror("pthread_create()");
		}
	}
	for(int i = 0; i < tnum; i++){
		pthread_join(t[i], NULL);
		if(ret == -1){
			perror("pthread_join()");
		}
		
	}
	pthread_join(scheduler_thread, NULL);
	return 0;	
}
