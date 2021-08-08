#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <pthread.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <semaphore.h>

#include "scheduler.h"

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
		printf("wait time:   %lf sec\n",(double)gettime(cn->arrive_time, cn->finish_time)/1000000);
	}
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

void scheduler_init(struct scheduler* sche){
	sche->running_node = NULL;
	sche->ready_head = sche->ready_tail = NULL;
	sche->finish_list = NULL;
	gettimeofday(&(sche->init_time), 0);
	sche->time_quantum = 0;
	sem_init(&(sche->sem), 0, 1);
}

void scheduler_show(struct scheduler* sche){
	struct ctl_node* cn = sche->running_node;
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
		printf("--------LAST FINISH--------\n");
		ctl_node_show(cn);
	}
	printf("---------------------------\n\n");
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
	sem_destroy(&(sche->sem));
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
	if(sche->ready_head == NULL){
		sche->ready_head = cn;
		sche->ready_tail = cn;
	}
	else{
		struct ctl_node* cn2 = sche->ready_head, *cn3 = NULL;
		if(cn->priority <= cn2->priority){
			cn->next = cn2;
			sche->ready_head = cn;
			return;
		}
		cn3 = cn2->next;
		while(cn3 != NULL){			
			if(cn->priority <= cn3->priority){
				cn2->next = cn;
				cn->next = cn3;
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
}

void enqueue_sjb(struct scheduler* sche, struct ctl_node* cn){
	if(sche->ready_head == NULL){
		sche->ready_head = cn;
		sche->ready_tail = cn;
	}
	else{
		struct ctl_node* cn2 = sche->ready_head, *cn3 = NULL;
		if(cn->worst_time <= cn2->worst_time){
			cn->next = cn2;
			sche->ready_head = cn;
			return;
		}
		cn3 = cn2->next;
		while(cn3 != NULL){			
			if(cn->worst_time <= cn3->worst_time){
				cn2->next = cn;
				cn->next = cn3;
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
}

struct ctl_node* dequeue_np(struct scheduler* sche){
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

void enqueue(struct scheduler* sche, struct ctl_node* cn, int mode){
	if(mode == FCFS){
		enqueue_fcfs(sche, cn);
	}
	else if(mode == PRIO){
		enqueue_prio(sche, cn);
	}
	else if(mode == SJB){
		enqueue_sjb(sche, cn);
	}
}

struct ctl_node* dequeue(struct scheduler* sche, int mode){
	if(mode == FCFS || mode == PRIO || mode == SJB){
		return dequeue_np(sche);
	}
	else{
		return NULL;
	}
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

