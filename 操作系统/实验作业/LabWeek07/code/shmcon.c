#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <sys/shm.h>
#include <fcntl.h>

#include "shmdata.h"

int main(int argc, char *argv[])
{
	struct stat fileattr;
	key_t key; 
	int shmid; 
	void *shmptr;
	struct shared_struct *shared; 
	char pathname[80], key_str[10], cmd_str[80];
	int shmsize, ret;
	
	//shmsize
	shmsize = sizeof(struct shared_struct);
	printf("[con] The heap's capacity is %d\n", NUM);

	if(argc < 2) {
		printf("[con] Usage: ./a.out pathname\n");
		return EXIT_FAILURE;
	}
	strcpy(pathname, argv[1]);
	if(stat(pathname, &fileattr) == -1) {
		ret = creat(pathname, O_RDWR);
		if (ret == -1) {
			ERR_EXIT("creat()");
		}
		printf("[con] Shared file object created\n");
	}
	
 	//key
	key = ftok(pathname, 0x27); 
	if(key == -1) {
		ERR_EXIT("shmcon: ftok()");
	}
	printf("[con] Key generated: IPC key = %x\n", key); 
	//shmid
	shmid = shmget((key_t)key, shmsize, 0666|PERM);
	if(shmid == -1) {
		ERR_EXIT("shmcon: shmget()");
	}
	printf("[con] Shmcon: shmid = %d\n", shmid);
	//shmptr
	shmptr = shmat(shmid, 0, 0); 
	if(shmptr == (void *)-1) {
		ERR_EXIT("shmcon: shmat()");
	}
	printf("[con] Shmcon: shared Memory attached at %p\n", shmptr);
	//shared
	shared = (struct shared_struct *)shmptr;
	
	// initialization 
	shared->mode = ACCESSIBLE;
	shared->size = 0;
	for(int i = 0; i < NUM + 1; i++){
		shared->heap[i].flag = DELETED;
	}
	
	sprintf(cmd_str, "ipcs -m | grep '%d'\n", shmid); 
	printf("\n------ Shared Memory Segments ------\n");
	system(cmd_str);
	printf("\n");
	
	sprintf(key_str, "%x", key);
	char *argv1[] = {" ", key_str, 0};

	int i = 0;
	while(i != -1){
		printf("[con] Enter '-1' to close the shared memory: ");
		scanf("%d",&i);
	}
	if (shmdt(shmptr) == -1) {
		ERR_EXIT("shmread: shmdt()");
	}
	
         /* shmid can be removed by any process knewn the IPC key */
	if (shmctl(shmid, IPC_RMID, 0) == -1) {
		ERR_EXIT("shmcon: shmctl(IPC_RMID)");
	}
	else {
		printf("[con] Shmcon: shmid = %d removed \n", shmid);
		printf("\n------ Shared Memory Segments ------\n");
		system(cmd_str);
		printf("\n[con] Nothing found ...\n"); 
	}

    exit(EXIT_SUCCESS);
}

