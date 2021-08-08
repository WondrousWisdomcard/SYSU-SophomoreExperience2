#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/stat.h>
#include <string.h>
#include <sys/shm.h>

#include "shmdata.h"

void request_show(){
	printf("[use] Enter '1' to add\n");  //查重
	printf("            '2' to delete\n"); 
	printf("            '3' to modify\n");  
	printf("            '4' to find\n");  
	printf("            '5' to resort\n"); 
	printf("            '6' to show\n");
	printf("            '0' to hang up\n");
	printf("           '-1' to quit\n");
}

void top_to_down(int i, struct shared_struct * shared){
	while(i <= shared->size){
		if(2*i <= shared->size && 2*i+1 <= shared->size){
			if(shared->heap[i].id > shared->heap[2 * i].id && shared->heap[2 * i].id <= shared->heap[2 * i + 1].id){
				struct shared_cell temp = shared->heap[i];
				shared->heap[i] = shared->heap[2*i];
				shared->heap[2*i] = temp;
				i = 2 * i;
			}
			else if(shared->heap[i].id > shared->heap[2 * i + 1].id && shared->heap[2 * i].id >= shared->heap[2 * i + 1].id){
				struct shared_cell temp = shared->heap[i];
				shared->heap[i] = shared->heap[2*i+1];
				shared->heap[2*i+1] = temp;
				i = 2 * i + 1;
			}
			else break;
		}
		else if(2*i <= shared->size && shared->heap[i].id > shared->heap[2 * i].id){
			struct shared_cell temp = shared->heap[i];
			shared->heap[i] = shared->heap[2*i];
			shared->heap[2*i] = temp;
			i = 2 * i;
		}
		else break;
	}
}

void down_to_top(int i, struct shared_struct * shared){
	while(i > 1){
		if(shared->heap[i].id < shared->heap[i/2].id){
			struct shared_cell temp = shared->heap[i];
			shared->heap[i] = shared->heap[i/2];
			shared->heap[i/2] = temp;
			i = i / 2;
		}
		else{
			break;
		}
	} 
}

struct shared_cell pop(struct shared_struct * shared){
	struct shared_cell empty;
	if(shared->size == 0){
		return empty;
	}
	struct shared_cell temp = shared->heap[1];
	shared->heap[1] = shared->heap[shared->size];
	shared->size--;
	top_to_down(1,shared);
	return temp;
}

void push(struct shared_cell cell, struct shared_struct * shared){
	if(shared->size + 1 == NUM){
		printf("[con] the memory is full\n");
		return;
	}

	shared->size++;
	shared->heap[shared->size] = cell;

	int i = shared->size;
	down_to_top(i, shared);
}

int request_call(struct shared_struct * shared){
	int i = -2;
	while(1){
		printf("[use] Enter: ");
		scanf("%d",&i);
		if(i == 1){ // Add mode
			struct shared_cell cell;
			cell.flag = ALIVED;
			printf("[use] Input the ID of student: ");
			scanf("%d",&(cell.id));
			printf("[use] Input the name of student: ");
			scanf("%s",cell.name);
			
			///// O(n)的查重
			int j;
			for(j = 1; j < shared->size + 1; j++){
				if(shared->heap[j].id == cell.id && shared->heap[j].flag == ALIVED){
					break;
				} 
			}
			if(j != shared->size + 1){
				printf("[use] That id has already existed\n");
			}
			else{
				push(cell, shared);
			}
		}
		else if(i == 2){ // Delete Mode
			int id;
			printf("[use] Input the ID of student: ");
			scanf("%d",&(id));
			for(int j = 1; j < shared->size + 1; j++){
				if(shared->heap[j].id == id){
					shared->heap[j].flag = DELETED;
				} 
			}
		}
		else if(i == 3){ // Modify Mode
			int id, j;
			printf("[use] Input the ID of student: ");
			scanf("%d",&(id));
			for(j = 1; j < shared->size + 1; j++){
				if(shared->heap[j].id == id && shared->heap[j].flag == ALIVED){
					break;
				} 
			}
			if(j == shared->size + 1){
				printf("[use] No that id");
			}
			else{
				printf("[use] Original: %8d   %s\n",shared->heap[j].id, shared->heap[j].name);
				printf("[use] Input the new name of student: ");
				scanf("%s",shared->heap[j].name);
			}			
		}
		else if(i == 4){ // Find Mode
			int id, j;
			printf("[use] Input the ID of student: ");
			scanf("%d",&(id));
			for(j = 1; j < shared->size + 1; j++){
				if(shared->heap[j].id == id && shared->heap[j].flag == ALIVED){
					break;
				} 
			}
			if(j == shared->size + 1){
				printf("[use] No that id\n");
			}
			else{
				printf("[use] ID: %d Name: %s\n",shared->heap[j].id, shared->heap[j].name);
				
			}		
		}
		else if(i == 5){ // Resort Mode
			for(int j = shared->size; j >= 1; j--){
				if(shared->heap[j].flag == DELETED){
					shared->heap[j] = shared->heap[shared->size];
					top_to_down(j,shared);
					shared->size--;
				} 
			}
		}
		else if(i == 6){ // Show Mode
		
			printf("[test] Heap size: %d\n", shared->size);
			
			printf("[use] Data table\n");
			printf("          ID      Name\n");
			struct shared_cell heap_t[NUM + 1];
			int t = shared->size;
			for(int i = 1; i < shared->size + 1; i++){
				heap_t[i] = shared->heap[i]; 
			}
			while(shared->size != 0){
				struct shared_cell j = pop(shared);
				if(j.flag == ALIVED){
					printf("       %8d   %s\n",j.id, j.name);
				}
			}
			shared->size = t;
			for(int i = 1; i < shared->size + 1; i++){
				shared->heap[i] = heap_t[i]; 
			}	
			
		}
		else if(i == 97){ // 强制查看内存单元
			printf("[test] Heap size: %d\n", shared->size);
			printf("[use] Data table\n");
			for(int i = 0; i < 11; i++){
				printf("%d,%d,%s\n",shared->heap[i].flag,shared->heap[i].id,shared->heap[i].name);
			}
		}
		else if(i == 98){ // 强制清空所有内容
			shared->size = 0;
			for(int i = 0; i < NUM+1; i++){
				shared->heap[i].flag = DELETED;
				shared->heap[i].id = 0;
				shared->heap[i].name[0] = '\0';
			}
		}
		else if(i == 0){ // 用户挂起，不结束程序
			printf("[use] Hang up\n");
			shared->mode = ACCESSIBLE;
			return 1;
		}
		else if(i == -1){ // 用户退出，结束进程
			printf("[use] Byeee\n");
			shared->mode = ACCESSIBLE;
			return 0;
		}
		else{
			printf("[use] Invalid input\n");
		}
	}
	return 0;
}

int main(int argc, char *argv[])
{
	void *shmptr = NULL;
	struct shared_struct *shared;
	int shmid;
	key_t key;
	char cmd_str[80];
	if(argc < 2) {
		printf("[use] Usage: ./a.out key\n");
		return EXIT_FAILURE;
	}

	sscanf(argv[1], "%x", &key);

	printf("[use] IPC key = %x\n", key);

	shmid = shmget((key_t)key, sizeof(struct shared_struct), 0666|PERM);
	if (shmid == -1) {
		ERR_EXIT("shread: shmget()");
	}

	shmptr = shmat(shmid, 0, 0);
	if(shmptr == (void *)-1) {
		ERR_EXIT("shread: shmat()");
	}
	printf("[use] shmid = %d\n", shmid);    
	printf("[use] shared memory attached at %p\n",shmptr);
	printf("[use] shmread process ready ...\n");

	shared = (struct shared_struct *)shmptr;
	sleep(1);

	sprintf(cmd_str, "ipcs -m | grep '%d'\n", shmid); 
	printf("\n------ Shared Memory Segments ------\n");
	system(cmd_str);
	printf("\n");
	while(1){
	
		while (shared->mode == BLOCKED) { // 共享内存被别的进程使用着，等待
			printf("[use] the memory is blocked, waiting...\n");
			sleep(1); 
		}
		shared->mode = BLOCKED;

		request_show();

		if(request_call(shared) == 0){ // 结束进程
			break;
		}
		else{ // 将进程挂起，休眠2秒
			sleep(2); 
		}
	}
	
	if (shmdt(shmptr) == -1) {
		ERR_EXIT("shmread: shmdt()");
	}
	
	exit(EXIT_SUCCESS); 
}
