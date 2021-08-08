#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <pthread.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <semaphore.h>
#include <signal.h>
#include <string.h>

#ifndef SCHEDULER
#define SCHEDULER

#define RUNNING 1
#define READY 0
#define BLOCK -1
#define END -2

#define FCFS 333
#define SJF 444
#define PRIO 555

#define P 9
#define NP 8
#define SIG 50
#define TIMELIMIT 10000000

long gettime(struct timeval ts, struct timeval te);

typedef struct ctl_node{
	int id;
	pthread_t ptid;
	struct timeval arrive_time; 
	struct timeval finish_time; 
	int worst_time;
	int rest_time;
	int re_sleep;
	int priority; // 0 the highest
	int state;
	struct ctl_node* next;
	sem_t start_sem; 
	sem_t finish_sem; 
}ctl_node; 

// control node operate
struct ctl_node* ctl_node_create(int id, int wct, int prio);
void ctl_node_show(struct ctl_node* cn);
void ctl_node_release(struct ctl_node* cn);

typedef struct scheduler{
	int mode; // np or p
	int mode_2; // fcfs or sjf or prio
	//running node
	struct ctl_node* running_node;
	
	//ready queue
	struct ctl_node* ready_head;
	struct ctl_node* ready_tail;
	
	//last finish
	struct ctl_node* finish_list;
	
	struct timeval init_time;
	long time_quantum;
	
	sem_t enqueue_sem; 
}scheduler;

// scheduler initialize
void scheduler_init(struct scheduler* sche, int mode);
void scheduler_show(struct scheduler* sche);
void scheduler_free(struct scheduler* sche);
void scheduler_delete(struct scheduler* sche);

void compute_average_wait_time(struct scheduler* sche);

// enqueue: other state to ready
// dequeue: ready to other state
void enqueue(struct scheduler* sche, struct ctl_node* cn, int mode);
struct ctl_node* dequeue(struct scheduler* sche, int mode);

// scheduler thread function
void *scheduler_np(void *sche);
void *scheduler_p(void *sche);
#endif

long gettime(struct timeval ts, struct timeval te){
	long time_start = (long) ts.tv_sec*1000*1000 + ts.tv_usec;
	long time_end = (long) te.tv_sec*1000*1000 + te.tv_usec;
	return time_end - time_start;
}

struct ctl_node* ctl_node_create(int id, int wct, int prio){
	struct ctl_node* cn = (struct ctl_node*)malloc(sizeof(struct ctl_node));
	gettimeofday(&(cn->arrive_time), 0);
	cn->id = id;
	cn->worst_time = wct;
	cn->rest_time = wct;
	cn->re_sleep = 0;
	cn->priority = prio;
	cn->state = READY;
	cn->next = NULL;
	sem_init(&(cn->start_sem), 0, 0);
	sem_init(&(cn->finish_sem), 0, 0);
	return cn;
}

void ctl_node_show(struct ctl_node* cn){
	if(cn == NULL){
		return;
	}
	printf("thread id:   %d\n",cn->id);
	if(cn->state == END){
		printf("wait time:   %lf sec\n",(double)gettime(cn->arrive_time, cn->finish_time)/1000000 - cn->worst_time);
	}
	printf("rest time:   %d\n", cn->rest_time);
	printf("worst time:  %d\n", cn->worst_time);
	printf("priority:    %d\n", cn->priority);
}

void ctl_node_release(struct ctl_node* cn){
	if(cn != NULL){
		sem_destroy(&(cn->start_sem));
		sem_destroy(&(cn->finish_sem));
		free(cn);
		cn = NULL;
	}
}

void scheduler_init(struct scheduler* sche, int mode){
	sche->mode = mode;
	sche->running_node = NULL;
	sche->ready_head = sche->ready_tail = NULL;
	sche->finish_list = NULL;
	gettimeofday(&(sche->init_time), 0);
	sche->time_quantum = 0;
	sem_init(&(sche->enqueue_sem), 0, 1);
}

void scheduler_show(struct scheduler* sche){
	struct ctl_node* cn = sche->running_node;
	struct timeval t_now;
	gettimeofday(&t_now, 0);
	long run_time = gettime(sche->init_time, t_now);
	
	printf("\n---SCHEDULER INFORMATION---\n");
	printf("Now: the %d seconds\n", (int)run_time/1000000);
	
	if(cn != NULL){
		printf("----------RUNNING----------\n");
		ctl_node_show(cn);
	}
	cn = sche->ready_head;
	if(cn != NULL){
		printf("-----------READY-----------\n");
		ctl_node_show(cn);
		cn = cn->next;
	}
	while(cn != NULL){
		printf("---------------------------\n");
		ctl_node_show(cn);
		cn = cn->next;
	}
	cn = sche->finish_list;
	if(cn != NULL){
		printf("--------FINISH TASK--------\n");
		ctl_node_show(cn);
		cn = cn->next;
	}
	while(cn != NULL){
		printf("---------------------------\n");
		ctl_node_show(cn);
		cn = cn->next;
	}
	printf("---------------------------\n\n");
}

void compute_average_wait_time(struct scheduler* sche){
	double aver_wait_time = 0;
	int c = 0;
	struct ctl_node* cn = sche->finish_list;
	while(cn != NULL){
		aver_wait_time += (double)gettime(cn->arrive_time, cn->finish_time)/1000000;
		aver_wait_time -= cn->worst_time;
		c++;
		cn = cn->next;
	}
	if(c == 0){
		printf("The average wait time is 0 sec\n");
	}
	else{
		printf("The average wait time is %.6lf sec\n", aver_wait_time/c);
	}
}

void scheduler_free(struct scheduler* sche){
	while(sche->running_node != NULL || sche->ready_head != NULL){
		printf("scheduler_free(): some threads is still running or waiting\n");
		sleep(1);
	}
	struct ctl_node* cn = sche->finish_list, *cn2;
	while(cn != NULL){
		cn2 = cn->next;
		ctl_node_release(cn);
		cn = cn2;
	}
	sche->finish_list = NULL;
}

void scheduler_delete(struct scheduler* sche){
	scheduler_show(sche);
	compute_average_wait_time(sche);
	scheduler_free(sche);
	printf("scheduler_delete(): succeed\n");
}

void enqueue_fcfs(struct scheduler* sche, struct ctl_node* cn){
	if(sche->ready_head == NULL){
		sche->ready_head = cn;
		sche->ready_tail = cn ;
	}
	else{
		sche->ready_tail->next = cn;
		sche->ready_tail = cn;
	}
}

void enqueue_prio(struct scheduler* sche, struct ctl_node* cn){
	sem_wait(&(sche->enqueue_sem));
	if(sche->ready_head == NULL){
		sche->ready_head = cn;
		sche->ready_tail = cn;
	}
	else{
		struct ctl_node* cn2 = sche->ready_head, *cn3 = NULL;
		if(cn->priority <= cn2->priority){
			cn->next = cn2;
			sche->ready_head = cn;
			sem_post(&(sche->enqueue_sem));
			return;
		}
		cn3 = cn2->next;
		if(cn3 == NULL){
			sche->ready_head->next = cn;
			sche->ready_tail = cn;
			cn->next = NULL;
			sem_post(&(sche->enqueue_sem));
			return;
		}
		while(cn3 != NULL){		
			if(cn->priority <= cn3->priority){
				cn2->next = cn;
				cn->next = cn3;
				sem_post(&(sche->enqueue_sem));
				return;
			}
			else{
				cn2 = cn3;
				cn3 = cn3->next;
			}
		}
		cn->next = sche->ready_tail;
		sche->ready_tail = cn;
		
	}
	sem_post(&(sche->enqueue_sem));
}

void enqueue_sjf(struct scheduler* sche, struct ctl_node* cn){
	sem_wait(&(sche->enqueue_sem));
	if(sche->ready_head == NULL){
		sche->ready_head = cn;
		sche->ready_tail = cn;
	}
	else{
		struct ctl_node* cn2 = sche->ready_head, *cn3 = NULL;
		if(cn->worst_time <= cn2->worst_time){
			cn->next = cn2;
			sche->ready_head = cn;
			sem_post(&(sche->enqueue_sem));
			return;
		}
		cn3 = cn2->next;
		if(cn3 == NULL){
			sche->ready_head->next = cn;
			sche->ready_tail = cn;
			cn->next = NULL;
			sem_post(&(sche->enqueue_sem));
			return;
		}
		while(cn3 != NULL){
			if(cn->worst_time <= cn3->worst_time){
				cn2->next = cn;
				cn->next = cn3;
				sem_post(&(sche->enqueue_sem));
				return;
			}
			else{
				cn2 = cn3;
				cn3 = cn3->next;
			}
		}
		cn->next = sche->ready_tail;
		sche->ready_tail = cn;
		
	}
	sem_post(&(sche->enqueue_sem));
}

void enqueue_np(struct scheduler* sche, struct ctl_node* cn, int mode){
	if(mode == FCFS){
		enqueue_fcfs(sche, cn);
	}
	else if(mode == PRIO){
		enqueue_prio(sche, cn);
	}
	else if(mode == SJF){
		enqueue_sjf(sche, cn);
	}
}

void enqueue_p(struct scheduler* sche, struct ctl_node* cn, int mode){
	struct ctl_node* run_cn = sche->running_node;
		
	if(run_cn == NULL){
		if(mode == FCFS){
			enqueue_fcfs(sche, cn);
		}
		else if(mode == PRIO){
			enqueue_prio(sche, cn);
		}
		else if(mode == SJF){
			enqueue_sjf(sche, cn);
		}
	}
	else{
		if(mode == FCFS){
			enqueue_fcfs(sche, cn);
		}
		else if(mode == PRIO){
			enqueue_prio(sche, cn);
			if(run_cn->priority > cn->priority){
				pthread_kill(run_cn->ptid, SIG);
			}
		}
		else if(mode == SJF){
			enqueue_sjf(sche, cn);
			struct timeval t_now;
			gettimeofday(&t_now, 0);
			if(run_cn->rest_time > cn->rest_time){
				pthread_kill(run_cn->ptid, SIG);
			}	
		}
	}
}

void enqueue(struct scheduler* sche, struct ctl_node* cn, int mode){
	sche->mode_2 = mode;
	if(sche->mode == NP){
		enqueue_np(sche, cn, mode);
	}
	else{
		enqueue_p(sche, cn, mode);
	}
}


struct ctl_node* dequeue(struct scheduler* sche, int mode){
	struct ctl_node* cn = sche->ready_head;
	if(cn == NULL){
		printf("dequeue(): empty ready queue\n");
	}
	else{
		sche->ready_head = sche->ready_head->next;
		cn->next = NULL;
		if(sche->ready_head == NULL){
			sche->ready_tail = NULL;
		}
	}
	return cn;
}

void *scheduler_np(void *par){
	struct scheduler *sche = (struct scheduler *)par;
	
	struct timeval tt;
	long t_s, t_e;
	gettimeofday(&tt, 0);
	t_s = tt.tv_sec * 1000 * 1000 + tt.tv_usec;
	
	while(1){
		if(sche->ready_head != NULL){
			struct ctl_node* cn = sche->ready_head;
			sem_post(&(cn->start_sem));
			dequeue(sche, FCFS);
			cn->state = RUNNING;
			sche->running_node = cn;
			
			sem_wait(&(cn->finish_sem));
			gettimeofday(&(cn->finish_time), 0);
			sche->running_node = NULL;
			cn->state = END;
			cn->rest_time = 0;
			cn->next = sche->finish_list;
			sche->finish_list = cn;
		}
		else{
			gettimeofday(&tt, 0);
			t_e = tt.tv_sec * 1000 * 1000 + tt.tv_usec;
			if(t_e - t_s > TIMELIMIT){
				break;
			}
		}
	}
	scheduler_delete(sche);
	pthread_exit(0);
}

void *scheduler_p(void *par){
	struct scheduler *sche = (struct scheduler *)par;
	
	struct timeval tt;
	long t_s, t_e;
	gettimeofday(&tt, 0);
	t_s = tt.tv_sec * 1000 * 1000 + tt.tv_usec;
	
	while(1){
		if(sche->ready_head != NULL){
			struct ctl_node* cn = sche->ready_head;
			cn->re_sleep = 0;
			sem_post(&(cn->start_sem));
			dequeue(sche, FCFS);
			cn->state = RUNNING;
			sche->running_node = cn;
			
			sem_wait(&(cn->finish_sem));
			
			if(sche->running_node->state == RUNNING){
				gettimeofday(&(cn->finish_time), 0);
				sche->running_node = NULL;
				cn->state = END;
				cn->rest_time = 0;
				cn->next = sche->finish_list;
				sche->finish_list = cn;
			}
			else if(sche->running_node->state == READY){
				struct ctl_node* run_cn = sche->running_node;
				sche->running_node = NULL;
				
				if(sche->mode_2 == PRIO){
					enqueue_prio(sche, run_cn);
				}
				else if(sche->mode_2 == SJF){
					enqueue_sjf(sche, run_cn);
				}
				sche->running_node = NULL;
			}
		}
		else{
			gettimeofday(&tt, 0);
			t_e = tt.tv_sec * 1000 * 1000 + tt.tv_usec;
			if(t_e - t_s > TIMELIMIT){
				break;
			}
		}
	}
	scheduler_delete(sche);
	pthread_exit(0);
}


struct scheduler sche;

static void *runner_np(void *par){
	
	struct ctl_node * cn = (struct ctl_node *)par; // [0]
	
	sem_wait(&(cn->start_sem)); // [1]
	
	printf("Thread %d will work %d second(s)\n",cn->id, cn->worst_time);
	sleep(cn->worst_time);
	scheduler_show(&sche);
	
	sem_post(&(cn->finish_sem)); // [2]
	pthread_exit(0);
}


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
	int mode = NP;
	int mode_2 = FCFS;
	
	if(argc == 3){
		if(argvs[1][0] == 'f' || argvs[1][0] == 'F'){
			mode_2 = FCFS;
		}
		else if(argvs[1][0] == 's' || argvs[1][0] == 'S'){
			mode_2 = SJF;
		}
		else if(argvs[1][0] == 'p' || argvs[1][0] == 'P'){
			mode_2 = PRIO;
		}
	
		if(argvs[2][0] == 'n' || argvs[2][0] == 'N'){
			mode = NP;
		}
		else if(argvs[2][0] == 'p' || argvs[2][0] == 'P'){
			mode = P;
		}
	}
	else{
		printf("NOTICE: you should add 2 runtime parameters:\n");
		printf("   The 1st must be 'fcfs', 'prio' or 'sjf'\n");
		printf("   The 2nd must be 'p' or 'np'\n");
		return(1);
	}
	
	if(mode == NP){
		printf("-----Scheduler Non Preemptive Test-----\n");
	}
	else{
		printf("-------Scheduler Preemptive Test-------\n");
	}
	printf("scheduler mode: %s %s\n",argvs[1], argvs[2]);
	
	printf("enter the arguments\n");
	printf("thread num: ");
	scanf("%d",&tnum);
	if(tnum <= 0){
		printf("main(): invalid thread num\n");
		return 1;
	}
	int run_t[tnum], start_t[tnum], pri[tnum];
	for(int i=0; i<tnum; i++){
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
	if(mode_2 == PRIO){
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

	scheduler_init(&sche, mode); // [3]
	pthread_t scheduler_thread;
	pthread_attr_t st;
	
	int ret = pthread_attr_init(&st);  // [4]
	if(ret == -1){
		perror("pthread_attr_init()");
	}
	if(mode == NP){
		pthread_create(&scheduler_thread, &st, &scheduler_np, (void *)(&sche));
	}
	else{
		pthread_create(&scheduler_thread, &st, &scheduler_p, (void *)(&sche)); 
	}
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
		
		ctl_node* cn = ctl_node_create(i+1, run_t[i], pri[i]); // [5]
		enqueue(&sche, cn, mode_2); // [5]
		if(mode == NP){
			pthread_create(t+i, at+i, &runner_np, (void *)(cn));
		}
		else{
			pthread_create(t+i, at+i, &runner_p, (void *)(cn));
		}
		
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


