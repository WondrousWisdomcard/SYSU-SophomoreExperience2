#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <sys/shm.h>
#include <fcntl.h>

#define SIZE 1900

#define PERM S_IRUSR|S_IWUSR|IPC_CREAT

#define ERR_EXIT(m) \
    do { \
        perror(m); \
        exit(EXIT_FAILURE); \
    } while(0)

/* a demo structure, modified as needed */
struct shared_struct {
    int lock;
    char M[SIZE];
};

int main(int argc, char *argv[])
{
    struct stat fileattr;
    key_t key; /* of type int */
    int shmid; /* shared memory ID */
    void *shmptr;
    struct shared_struct *shared; /* structured shm */
    pid_t childpid1, childpid2;
    char pathname[80], key_str[10], cmd_str[80];
    long long int shmsize, ret, add = 1000000;
	for(shmsize = 10000; ; shmsize+=add){
		
		if(argc < 2) {
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
		
		key = ftok(pathname, 0x27); /* 0x27 a project ID 0x0001 - 0xffff, 8 least bits used */
		if(key == -1) {
			ERR_EXIT("shmcon: ftok()");
		}
		
		shmid = shmget((key_t)key, shmsize, 0666|PERM);
		if(shmid == -1) {
			printf("shm size = %lld\n", shmsize);
			printf("key generated: IPC key = %x\n", key); /* can set any nonzero key without ftok()*/
			ERR_EXIT("shmcon: shmget()");
			
		}

		if (shmctl(shmid, IPC_RMID, 0) == -1) {
			ERR_EXIT("shmcon: shmctl(IPC_RMID)");
		}
	}
    exit(EXIT_SUCCESS);
}

