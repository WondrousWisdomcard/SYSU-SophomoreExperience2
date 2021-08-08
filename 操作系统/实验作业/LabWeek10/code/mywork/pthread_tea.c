#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <sys/time.h>
#include <ctype.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <sys/shm.h>
#include <fcntl.h>

int pnum = 6;
int num = 10000;

#define BUSY 1
#define IDLE 0

struct shared_struct{
	int stat;
	int num;
};

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
			return 1;
		}
		pthread_create(t+i, at+i, &runner, (void *)(key+i));
		if(ret == -1){
			perror("pthread_create()");
			return 1;
		}
	}
	
	for(int i = 0; i < pnum; i++){
		pthread_join(t[i], (void **)(ans+i));
		if(ret == -1){
			perror("pthread_join()");
			return 1;
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
	
	key_t key2;
	int shmid;
	void* shmptr;
	struct shared_struct *shared;
	char* pathname = "./hi";
	int shmsize = sizeof(struct shared_struct);
	
	struct stat fileattr;
	if(stat(pathname, &fileattr) == -1){
		int ret = creat(pathname, O_RDWR);
		if(ret == -1){
			perror("creat()");
			return 1;
		}
		printf("file creat\n");
	}
	key2 = ftok(pathname, 0x27);
	if(key2 == -1){
		perror("ftok()");
		return 1;
	}
	printf("key: %d\n", key2);

	shmid = shmget((key_t)key2, shmsize, 0666|S_IWUSR|S_IRUSR|IPC_CREAT);	
	if(shmid == -1){
		perror("shmget()");
		return 1;
	}
	printf("shmid: %d\n",shmid);
	
	shmptr = shmat(shmid, 0, 0);
	if(shmptr == NULL){
		perror("shmat()");
		return 1;
	}
	printf("shmptr: %p\n",shmptr);
	
	shared = (struct shared_struct *)shmptr;
	shared->stat = BUSY;
	shared->num = aans;
	shared->stat = IDLE;
	
	if(shmdt(shmptr) == -1){
		perror("shmdt()");
		return 1;
	}
	
	if(shmctl(shmid, IPC_RMID, 0) == -1){
		perror("shmctl()");
		return 1;
	}
	
	otherwise();
	return 0;  
}
