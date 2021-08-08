#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <pthread.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <semaphore.h>
#include <signal.h>

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
		if(cn->rest_time <= cn2->rest_time){
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
			if(cn->rest_time <= cn3->rest_time){
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
