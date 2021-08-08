#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

#ifndef THREAD_POOL
#define THREAD_POOL

#define OPEN 1
#define CLOSE 0

typedef struct task{
	int task_id;
	void* (*func)(void*);
	void* arg;
}task;

typedef struct thread_pool{	
	pthread_mutex_t lock;
	
	int state;
	pthread_t* manager;
	
	pthread_t* thread_list;
	int thread_list_size;
	int thread_list_max_size;
	int busy_thread_num;
	
	struct task* task_queue; // circular queue
	int task_queue_size;
	int task_queue_head;
	int task_queue_tail; // to empty
}thread_pool;

static void* thread_runner(void* arg);

static void* thread_manager(void* arg);

struct thread_pool* thread_pool_create(int tp_num_init, int tp_num_max, int tq_num);

int thread_pool_free(struct thread_pool* tp);

int thread_pool_destory(struct thread_pool* tp);

int thread_pool_show(struct thread_pool* tp); 

int thread_pool_wait(struct thread_pool* tp); 

int task_create(struct thread_pool* tp, int task_id, void* (*func)(void *), void* arg);

#endif
