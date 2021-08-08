/*  compiling with -lpthread

    this version works properly
	file list:
		syn-pc-con-6.h
		syn-pc-con-6.c
		syn-pc-producer-6.c
		syn-pc-consumer-6.c
    with process shared memory and semaphores
    BUFFER_SIZE, MAX_ITEM_NUM, THREAD_PRO and THREAD_CONS got from input
*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/shm.h>
#include <semaphore.h>
#include <wait.h>
#include "alg.18-6-syn-pc-con-6.h"

int shmid;
void *shm = NULL;
int detachshm(void);

/*
    USAGE: syn-pc-con-6.o shared-object-name
    shared-object-name is a filename or a path (like /home/myshm) that should be exist
*/

int main(int argc, char *argv[])
{
    pid_t childpid, pro_pid, cons_pid;
    struct stat statbuf;
    int buffer_size, max_item_num, thread_pro, thread_cons;
    
    if (argc < 2) {
        printf("\nshared file object undeclared!\nUsage: syn-pc-con-6.o /home/myshm\n");
        return EXIT_FAILURE;
    }
    if (stat(argv[1], &statbuf) == -1) {
        perror("stat()");
        return EXIT_FAILURE;
    }
	
    while (1) {
        printf("Pls input the buffer size(1-100, 0 quit): ");
        scanf("%d", &buffer_size);
        if (buffer_size <= 0) return 0;
        if (buffer_size > 100) continue;
        printf("Pls input the max number of items to be produced(1-10000, 0 quit): ");
        scanf("%d", &max_item_num);
        if (max_item_num <= 0) return 0;
        if (max_item_num > 10000) continue;
        printf("Pls input the number of producers(1-500, 0 quit): ");
        scanf("%d", &thread_pro);
        if (thread_pro <= 0) return 0;
        if (thread_pro < 0) continue;
        printf("Pls input the number of consumers(1-500, 0 quit): ");
        scanf("%d", &thread_cons);
        if (thread_cons <= 0) return 0;
        if (thread_cons < 0) continue;
        break;
    }

    struct ctln_pc_st *ctln = NULL;
    struct data_pc_st *data = NULL;
    key_t key;
    int ret;

    if ((key = ftok(argv[1], 0x28)) < 0) { 
        perror("ftok()");
        exit(EXIT_FAILURE);
    }
    
      /* get the shared memoey
         'invalid argument':
	    If the size exceeds the current shmmax.
	    If the shmid exists, its size is defined when it was firstly declared and can not be changed.
	    If you want a lager size, you have to alter a new key for a new shmid
      */
    shmid = shmget((key_t)key, (buffer_size + BASE_ADDR)*sizeof(struct data_pc_st), 0666 | IPC_CREAT);
    if (shmid == -1) {
        perror("shmget()");
        exit(EXIT_FAILURE);
    }

      /* attach the created shared memory to user space */
    shm = shmat(shmid, 0, 0);
    if (shm == (void *)-1) {
        perror("shmat()");
        exit(EXIT_FAILURE);
    }

      /* set the shared memory, initialize all control para
         The first 10 units of shared memory are reserved for control para. Data start from the unit indexed 10
         circular data queue is indicated by (enqueue | dequeue) % buffer_size + BASE_ADDR */ 
    ctln = (struct ctln_pc_st *)shm;
    data = (struct data_pc_st *)shm;

    ctln->BUFFER_SIZE = buffer_size;
    ctln->MAX_ITEM_NUM = max_item_num;
    ctln->THREAD_PRO = thread_pro;
    ctln->THREAD_CONS = thread_cons; 
    ctln->item_num = 0;
    ctln->consume_num = 0;
    ctln->enqueue = 0;
    ctln->dequeue = 0;
    ctln->END_FLAG = 0;

    ret = sem_init(&ctln->sem_mutex, 1, 1); /* the second parameter of sem_init must be set to non-zero for inter process sharing */
    if (ret == -1) {
        perror("sem_init-mutex");
        return detachshm();
    }
    ret = sem_init(&ctln->stock, 1, 0); /* initialize to 0 */
    if (ret == -1) {
        perror("sem_init-stock");
        return detachshm();
    }
    ret = sem_init(&ctln->emptyslot, 1, ctln->BUFFER_SIZE); /*initialize to BUFFER_SIZE */
    if (ret == -1) {
        perror("sem_init-emptyslot");
        return detachshm();
    }

    printf("\nsyn-pc-con console pid = %d\n", getpid());

    char *argv1[3];
    char execname[] = "./";
    char shmidstring[10];
    sprintf(shmidstring, "%d", shmid);
    argv1[0] = execname;
    argv1[1] = shmidstring;
    argv1[2] = NULL;
        
    childpid = vfork();
    if (childpid < 0) {
        perror("first fork");
        return detachshm();
    } 
    else if (childpid == 0) { /* call the producer */ 
        pro_pid = getpid();
        printf("producer pid = %d, shmid = %s\n", pro_pid, argv1[1]);
        execv("./p.o", argv1);
    }
    else {
        childpid = vfork();
        if (childpid < 0) {
            perror("second fork");
            return detachshm();
        } 
        else if (childpid == 0) { /* call the consumer */
            cons_pid = getpid();
            printf("consumer pid = %d, shmid = %s\n", cons_pid, argv1[1]);
            execv("./c.o", argv1);
        }
    }

    if (waitpid(pro_pid, 0, 0) != pro_pid) /* block wait */
        perror("wait pro");
    else
        printf("waiting pro_pid %d success.\n", pro_pid);

    if (waitpid(cons_pid, 0, 0) != cons_pid)
        perror("wait cons");
    else
        printf("waiting cons_pid %d success.\n", cons_pid);
        
    ret = sem_destroy(&ctln->sem_mutex);
    if (ret == -1)
        perror("sem_destroy sem_mutex");
    ret = sem_destroy(&ctln->stock); /* sem_destroy() will not affect the sem_wait() calling process */
    if (ret == -1)
        perror("sem_destroy stock");
    ret = sem_destroy(&ctln->emptyslot);
    if (ret == -1)
        perror("sem_destroy empty_slot");

    return detachshm();
}

int detachshm(void)
{
    if (shmdt(shm) == -1) {
        perror("shmdt()");
        exit(EXIT_FAILURE);
    }
    if (shmctl(shmid, IPC_RMID, 0) == -1) {
        perror("shmctl(IPC_RMID)");
        exit(EXIT_FAILURE);
    }
}
