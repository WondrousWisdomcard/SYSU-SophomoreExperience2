#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <pthread.h>
#include <signal.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <sys/shm.h>

#include "pshmdata.h"

#define PNUM_R 10
#define PNUM_W 5

void show_shm(char * cmd_str){
	printf("\n------ Shared Memory Segments ------\n");
    system(cmd_str);
}

int main(int argc, char *argv[])
{
    struct stat fileattr;
    key_t key; // of type int
    int shmid; // shared memory ID 
    void *shmptr;
    struct shared_struct *shared; // structured shm
    
    pid_t childpid1, childpid2;
    char pathname[80], key_str[10], cmd_str[80];
    int shmsize, ret;

    shmsize = TEXT_NUM*sizeof(struct shared_struct);
    printf("max record number = %d, shm size = %d\n", TEXT_NUM, shmsize);

	// file check
    if(argc <2) {
        printf("Usage: ./a.out pathname\n");
        return EXIT_FAILURE;
    }
    strcpy(pathname, argv[1]);

    if(stat(pathname, &fileattr) == -1) {
        ret = creat(pathname, O_RDWR);
        if (ret == -1) {
            ERR_EXIT("creat()");
        }
        printf("shared file object created\n");
    }
 
 	// ftok
    key = ftok(pathname, 0x27);
    if(key == -1) {
        ERR_EXIT("shmcon: ftok()");
    }
    printf("key generated: IPC key = %x\n", key);

	// shmget
    shmid = shmget((key_t)key, shmsize, 0666|PERM);
    if(shmid == -1) {
        ERR_EXIT("shmcon: shmget()");
    }
    printf("shmcon: shmid = %d\n", shmid);

	// shmat
    shmptr = shmat(shmid, 0, 0); 
    if(shmptr == (void *)-1) {
        ERR_EXIT("shmcon: shmat()");
    }
    printf("shmcon: shared Memory attached at %p\n", shmptr);
    
    // init shared memory
    shared = (struct shared_struct *)shmptr;
    shared->pnum_r = PNUM_R;
    shared->pnum_w = PNUM_W;
    shared->pnum_cs = 0;
    shared->last_read = -1;
    shared->last_write = -1;
    
    memset(shared->level, (-1), sizeof(shared->level));
    memset(shared->waiting, (-1), sizeof(shared->waiting));
    
    // ipcs check 1
    sprintf(cmd_str, "ipcs -m | grep '%d'\n", shmid); 
    show_shm(cmd_str);
	
	// shmdt
    if(shmdt(shmptr) == -1) {
        ERR_EXIT("shmcon: shmdt()");
    }
    
    // ipcs check 2
    show_shm(cmd_str);

	// arg make
    sprintf(key_str, "%x", key);
    char *argv1[] = {" ", key_str, 0};

	// write process
    childpid1 = vfork();
    if(childpid1 < 0) {
        ERR_EXIT("shmcon: 1st vfork()");
    } 
    else if(childpid1 == 0) {
        execv("./pshmwrite.o", argv1);
    }
    else {
    
    	// read process
        childpid2 = vfork();
        if(childpid2 < 0) {
            ERR_EXIT("shmcon: 2nd vfork()");
        }
        else if (childpid2 == 0) {
            execv("./pshmread.o", argv1);
        }
        else {
            wait(&childpid1);
            wait(&childpid2);
            
            // shmctl
            if (shmctl(shmid, IPC_RMID, 0) == -1) {
                ERR_EXIT("shmcon: shmctl(IPC_RMID)");
            }
            else {
            
            	// ipcs check 3
                printf("\nshmcon: shmid = %d removed \n", shmid);
                show_shm(cmd_str);
                printf("nothing found ...\n"); 
            }
        }
    }
    exit(EXIT_SUCCESS);
}

