#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <sys/time.h>
#include <unistd.h>

#define PNUM 6
// 计算 n 内质数的个数

int n = 10000;

static void *runner(void *par){
	//sleep(1);
	int * a = (int *)par;
	int m = a[0];
	int i,j = 0;
	//printf("Thread: %d Tid: %lu\n", m, pthread_self());
	//printf("%d\n",a[0]);
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
			printf("Thread %d : %d is a prime numer\n",m,i);
		} 
	}
	pthread_exit(0);
}

void otherwise(){
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
	printf("\nThen we don't use multi-threads to compute, cost %ld us\n", te-ts);
	printf("And The result is %d\n",ans);
	
}


int main(int argc, char* argvs[]){
	if(argc == 2){
		n = atoi(argvs[1]); 
		if(n <= 2){
			printf("Inproper input!\n");
			return 1;
		}
	}
	printf("Let find the prime number num from 2 to %d\n",n);
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
			return 1;
		}
	}
	for(int i = 0; i < PNUM; i++){
		int ret = pthread_join(ptid[i], NULL);
		if(ret == -1){
			perror("pthread_create()");
			return 1;
		}
	}
	// 我想知道 join 和 create 带入的参数差别
	int ans = 0;
	for(int i = 0; i < PNUM; i++){
		printf("Thread %d calculated %d prime number\n", i ,args[i][1]);
		ans += args[i][1];
	}
	ans++;
	
	gettimeofday(&t, 0);
	te = (long) t.tv_sec*1000*1000 + t.tv_usec;
	
	printf("The result is %d\n",ans);
	
	printf("We use %d threads to compute, cost %ld us\n", PNUM, te-ts);
	
	//otherwise
	otherwise();
	
	return 0;
	
}
