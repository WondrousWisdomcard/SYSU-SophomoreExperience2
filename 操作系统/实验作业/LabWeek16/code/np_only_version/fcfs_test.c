#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <pthread.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <semaphore.h>

#include "scheduler.h"

/*
测试代码与调度代码的分离：
	-基于我们实现的模拟CPU调度库，这个程序可以测试任意一种CPU调度模式，修改mode即可
	-使用调度器库函数进行调度测试需要注意的要点，在代码中用序号标注了，共有6点:
		-[0] 用户需将线程对应的线程控制单元(ctl_node)传入线程函数
		-[1] 运行前需等待信号量start_sem以被调度
		-[2] 运行结束需释放信号量start_sem以通知调度器
		-[3] 调度器需要初始化，调用scheduler_init函数即可
		-[4] 需要创建单独的调度器管理线程，该线程执行的线程函数(非阻塞）scheduler，模拟调度器库已经将其实现
		-[5] 每创建一个待调度县城，需要调用ctl_node_create()创建线程管理单元ctl_node，并调用enqueue()函数，入队的模式可以是FCFS、SJB、PRIO，分别对应不同的调度策略
*/ 

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
	
	printf("------------FCFS TEST INPUT------------\n");
	printf("enter the args of fcfs-test\n");
	printf("NOTICE: start time must be incremental\n");	
	printf("thread num: ");
	scanf("%d",&pnum);
	if(pnum <= 0){
		printf("fcfs_test(): invalid thread num\n");
		return 1;
	}
	int run_t[pnum],start_t[pnum];
	for(int i = 0; i < pnum; i++){
		printf("start time (sec) of thread-%d: ", i+1);
		scanf("%d",start_t+i);
		if(start_t[i] < 0){
			printf("fcfs_test(): invalid start time\n");
			return 1;
		}
	}
	for(int i = 0; i < pnum; i++){
		printf("run time (sec) of thread-%d: ", i+1);
		scanf("%d",run_t+i);	
		if(run_t[i] < 0){
			printf("fcfs_test(): invalid run time\n");
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
		enqueue(&sche, cn, FCFS); // [5]
		
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
