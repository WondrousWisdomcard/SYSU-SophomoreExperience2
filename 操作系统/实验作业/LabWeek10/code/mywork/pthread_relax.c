#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <sys/time.h>
#include <ctype.h>

int pnum = 6;
int num = 10000;


void otherwise(){
	int ans = 0,i,j;
	long ts = 0, te = 0;
	struct timeval t; 
	
	gettimeofday(&t, 0);
	ts = (long) t.tv_sec*1000*1000 + t.tv_usec;
	
	for(i = 3; i <= num; i += 2){
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


static void *runner(void * param){
	int m = *((int *)param);
	int* ans = (int *)malloc(sizeof(int));  
	for(int i = m; i < num; i += (pnum+1)){
		if(i < 2){
			continue;
		}
		else if(i == 2){
			//printf("Thread %d: %d is prime number\n", m, i);
			(*ans) ++;
		}
		else{
			int j = 0;
			for(j = 2; j < i; j++){
				if(i % j == 0){
					break;
				}
			}
			if(i == j){
				//printf("Thread %d: %d is prime number\n", m, i);
				(*ans) ++;
			}
		}
	}
	pthread_exit(ans);
}
int main(int argc, char *argvs[]){
	int ret;
	if(argc == 3){
		pnum = atoi(argvs[1]);
		num = atoi(argvs[2]);
	}
	
	pthread_t t[pnum];
	pthread_attr_t at[pnum];
	int key[pnum];
	int* ans[pnum];
	
	struct timeval tt;
	long t_s, t_e;
	gettimeofday(&tt, 0);
	t_s = tt.tv_sec * 1000 * 1000 + tt.tv_usec;
	for(int i = 0; i < pnum; i++){
		key[i] = i+1;
		ret = pthread_attr_init(at+i);
		if(ret == -1){
			perror("pthread_attr_init()");
		}
		pthread_create(t+i, at+i, &runner, (void *)(key+i));
		if(ret == -1){
			perror("pthread_create()");
		}
	}
	
	for(int i = 0; i < pnum; i++){
		pthread_join(t[i], (void **)(ans+i));
		if(ret == -1){
			perror("pthread_join()");
		}
		
	}
	
	int aans = 0;
	
	int i = pnum + 1;
	int j = 0;
	for(j = 2; j < i; j++){
		if(i % j == 0){
			break;
		}
	}
	if(i == j){
		//printf("Thread %d: %d is prime number\n", 0, i);
		aans ++;
	}
	
	for(int i = 0; i < pnum; i++){
		printf("Thread %d get %d prime number\n", key[i], *ans[i]);
		aans += *ans[i];
	}
	
	gettimeofday(&tt, 0);
	t_e = tt.tv_sec * 1000 * 1000 + tt.tv_usec;
	
	printf("Total number of prime number between %d to %d is %d\n", 2, num-1, aans);
	printf("We use %d threads, we cost %ld us\n", pnum, t_e - t_s);
	
	otherwise();
	return 0;  
}
