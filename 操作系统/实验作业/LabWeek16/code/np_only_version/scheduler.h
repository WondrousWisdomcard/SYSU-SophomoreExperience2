#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <pthread.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <semaphore.h>

#ifndef SCHEDULER
#define SCHEDULER

#define RUNNING 1
#define READY 0
#define BLOCK -1
#define END -2

#define FCFS 333
#define SJB 444
#define PRIO 555

#define TIMELIMIT 60000000

typedef struct ctl_node{
	int id;
	struct timeval arrive_time; 
	struct timeval finish_time; 
	int worst_time;
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
	//running node
	struct ctl_node* running_node;
	
	//ready queue
	struct ctl_node* ready_head;
	struct ctl_node* ready_tail;
	
	//last finish
	struct ctl_node* finish_list;
	
	struct timeval init_time;
	long time_quantum;
	sem_t sem;
}scheduler;

// scheduler initialize
void scheduler_init(struct scheduler* sche);
void scheduler_show(struct scheduler* sche);
void scheduler_free(struct scheduler* sche);
void scheduler_delete(struct scheduler* sche);

// enqueue: other state to ready
// dequeue: ready to other state
void enqueue(struct scheduler* sche, struct ctl_node* cn, int mode);
struct ctl_node* dequeue(struct scheduler* sche, int mode);

// scheduler thread function
void *scheduler_np(void *sche);
void *scheduler_p(void *sche);
#endif






