#include "thread_pool.h"

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <pthread.h>

struct thread_pool* thread_pool_create(int tp_num_init, int tp_num_max, int tq_num){
	int flag = 0;
	// para check
	if(tq_num <= 0){
		printf("thread_pool_create(): invalid tq_num\n");
		return NULL;
	}
	else if(tp_num_init <= 0 || tp_num_max <= tp_num_init){
		printf("thread_pool_create(): invalid tp_num\n");
		return NULL;
	}
	
	// thread pool/lock/manager/state init
	struct thread_pool* tp = (struct thread_pool*)malloc(sizeof(thread_pool));
	if(tp == NULL){
		perror("malloc()");
        flag = 1;
	}
	if(pthread_mutex_init(&(tp->lock), NULL) != 0){
		perror("pthread_mutex_init()");
		flag = 1;
    }
    tp->manager = (pthread_t*)malloc(sizeof(pthread_t));
	if(tp->manager == NULL){
		perror("malloc()");
        flag = 1;
	}	
	tp->state = OPEN;

	// thread list init
	tp->thread_list = (pthread_t*)malloc(tp_num_max * sizeof(pthread_t));
	if(tp->thread_list == NULL){
		perror("malloc()");
        	flag = 1;
	}
	tp->thread_list_size = tp_num_init;
	tp->thread_list_max_size = tp_num_max;
	tp->busy_thread_num = 0;

	// task queue init
	tp->task_queue = (struct task*)malloc(tq_num * sizeof(struct task));
	if(tp->task_queue == NULL){
		perror("malloc()");
        	flag = 1;
	}
	tp->task_queue_size = tq_num;
	tp->task_queue_head = 0;
	tp->task_queue_tail = 0;
	for(int i = 0; i < tq_num; i++){
		tp->task_queue[i].task_id = 0;
		tp->task_queue[i].arg = NULL;
		tp->task_queue[i].func = NULL;
	}

	// runner/manager init
	int ret = pthread_create(tp->manager, NULL, thread_manager, (void *)tp);
	if(ret == -1){
		perror("pthread_create()");
		flag = 1;
	}
	for(int i = 0; i < tp->thread_list_size; i++){
		ret = pthread_create((tp->thread_list) + i, NULL, thread_runner, (void *)tp);
		if(ret == -1){
			perror("pthread_create()");
			flag = 1;
		}
	}
	if(flag == 1){
		thread_pool_free(tp);
		return NULL;
	}

	//printf("thread pool address: %p\n",tp);
	return tp;
}

int thread_pool_free(struct thread_pool* tp){
	if(tp == NULL){
		printf("thread_pool_free(): thread pool not exist\n");
		return -1;
	}
	pthread_mutex_lock(&(tp->lock));
	pthread_mutex_destroy(&(tp->lock));
	if(tp->manager)
		free(tp->manager);
	if(tp->thread_list)
		free(tp->thread_list);
	if(tp->task_queue)
		free(tp->task_queue);
	free(tp);
	tp = NULL;
	return 0;
}

int thread_pool_wait(struct thread_pool* tp){
	while(1){
		pthread_mutex_lock(&(tp->lock));
		if(tp->task_queue_head == tp->task_queue_tail){
			pthread_mutex_unlock(&(tp->lock));
			break;
		}
		pthread_mutex_unlock(&(tp->lock));
	}
	return 0;
}


int thread_pool_destory(struct thread_pool* tp){
	if(tp == NULL){
		printf("thread_pool_destory(): thread pool not exist\n");
		return -1;
	}
	tp->state = CLOSE;
	//pthread_join(*(tp->manager), NULL);
	for(int i = 0; i < tp->thread_list_size; i++){
		pthread_join(tp->thread_list[i], NULL);
	}
	thread_pool_free(tp);
	return 0;
}

static void* thread_runner(void* arg){
	struct thread_pool* tp = (struct thread_pool*)arg;
	struct task t;
	while(1){
		pthread_mutex_lock(&(tp->lock));
		if(tp->state == CLOSE){
			pthread_mutex_unlock(&(tp->lock));
			break;
		}
		
		// wait for new task
		if(tp->task_queue_head == tp->task_queue_tail && tp->state == OPEN){
			pthread_mutex_unlock(&(tp->lock));
			continue;
		}
		// get a task
		t.task_id = tp->task_queue[tp->task_queue_head].task_id;
		t.func = tp->task_queue[tp->task_queue_head].func;
		t.arg = tp->task_queue[tp->task_queue_head].arg;
		tp->task_queue_head = (tp->task_queue_head + 1) % tp->task_queue_size;
		tp->busy_thread_num++;
		
		pthread_mutex_unlock(&(tp->lock));
		
		// run the task
		//printf("thread_runner(): thread-%d busy, running task-%d\n",(int)pthread_self(), t.task_id);
		(*t.func)(t.arg); 
		//sleep(1);
		
		// task finish
		pthread_mutex_lock(&(tp->lock));
		tp->busy_thread_num--;
		pthread_mutex_unlock(&(tp->lock));
		//printf("thread_runner(): thread-%d now free\n",(int)pthread_self());
	}
	
	pthread_exit(NULL);
}

static void* thread_manager(void* arg){
	int flag_max = 0, i = 0;
	struct thread_pool* tp = (struct thread_pool*)arg;
	while(1){
		if(tp->state == CLOSE){
			break;
		}
		if(tp->thread_list_size == tp->thread_list_max_size){
			flag_max = 1;
		}
		// thread add trigger
		if(flag_max != 1){
			pthread_mutex_lock(&(tp->lock));
			int queue_n = tp->task_queue_tail - tp->task_queue_head;
			if(queue_n < 0){
				queue_n += tp->task_queue_size;
			}

			// if there exist more than 50% waiting task, add threads to thread pool 
			if(queue_n > tp->task_queue_size / 2){
				for(i = 0; i < tp->thread_list_size; i++){
					if(i + tp->thread_list_size == tp->thread_list_max_size){
						break;
					}
					int ret = pthread_create((tp->thread_list) + i + tp->thread_list_size, NULL, thread_runner, (void *)tp);
					if(ret == -1){
						perror("pthread_create()");
						break;
					}
				}
				tp->thread_list_size += i;
				flag_max = 0;
			}
			pthread_mutex_unlock(&(tp->lock));
		}
		
		// thread destory trigger
		// ...
	}
}

int task_create(struct thread_pool* tp, int task_id, void* (*func)(void *), void* arg){
	
	int queue_n = 0;
	while(1){
		pthread_mutex_lock(&(tp->lock));
	
		queue_n = tp->task_queue_tail - tp->task_queue_head;
		if(queue_n < 0){
			queue_n += tp->task_queue_size;
		}
		if(tp->state == OPEN && queue_n == tp->task_queue_size - 1){
			pthread_mutex_unlock(&(tp->lock));
			//sleep(1);
		}
		else if(tp->state == OPEN && queue_n < tp->task_queue_size){
			tp->task_queue[tp->task_queue_tail].task_id = task_id;
			tp->task_queue[tp->task_queue_tail].func = func;
			tp->task_queue[tp->task_queue_tail].arg = arg;
			tp->task_queue_tail = (tp->task_queue_tail + 1) % tp->task_queue_size;
		
			pthread_mutex_unlock(&(tp->lock));
			return 0;
		}
		else{
			pthread_mutex_unlock(&(tp->lock));
			return -1;
		}
	}
	return -1;	
}

int thread_pool_show(struct thread_pool* tp){
	if(tp == NULL){
		return 1;
	}
	int i = 0, j = 0;
	pthread_mutex_lock(&(tp->lock));
	int queue_n = tp->task_queue_tail - tp->task_queue_head;
	if(queue_n < 0){
		queue_n += tp->task_queue_size;
	}
	
	printf("-----------------------------\n");
	printf("   Thread Pool Information   \n");
	printf("-----------------------------\n");
	if(tp->state == OPEN){
		printf("   State: OPEN\n");
	}
	else{
		printf("   State: CLOSE\n");
	}
	printf("   Manager ID: %ld\n",*(tp->manager)%100);
	printf("\n");
	printf("   Thread List Size: %d\n", tp->thread_list_size);
	printf("   Thread List Limit: %d\n", tp->thread_list_max_size);
	printf("   Busy Thread Number: %d\n", tp->busy_thread_num); 
	printf("   All Thread ID:\n   ");
	for(i = 0; i < tp->thread_list_size; i++){
		printf("%3ld ", tp->thread_list[i]%100);
		if((i+1) % 5 == 0){
			printf("\n   ");
		}
	}
	printf("\n");
	printf("   Task Queue Size: %d\n", tp->task_queue_size);
	printf("   Task Queue Head: %d\n", tp->task_queue_head);
	printf("   Task Queue Tail: %d\n", tp->task_queue_tail); 
	printf("   All Task ID:\n   ");
	for(i = 0; i < queue_n; i++){
		j = i + tp->task_queue_head;
		if(j >= tp->task_queue_size){
			j -= tp->task_queue_size;
		}
		printf("%3d ", tp->task_queue[j].task_id);
		if((i+1) % 5 == 0){
			printf("\n   ");
		}
	}
	printf("\n-----------------------------\n\n");
	pthread_mutex_unlock(&(tp->lock));
	return 0;
}

