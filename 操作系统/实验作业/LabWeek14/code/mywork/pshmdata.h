#define TEXT_SIZE 4096
#define TEXT_NUM 1
#define MAX_N 1024
 

struct shared_struct {

	int pnum_r; // number of read process
	int pnum_w; // number of write process
	int pnum_cs; // number of process in critical section
	
	int level[MAX_N]; // level of processes 0 ... pnum
	int waiting[MAX_N-1]; // waiting process of each level 0 ... pnum-1
	
	int last_read; // last read thread id
	int last_write; // last write thread id
    char mtext[TEXT_SIZE]; // shm text
};

#define PERM S_IRUSR|S_IWUSR|IPC_CREAT

#define ERR_EXIT(m) \
    do { \
        perror(m); \
        exit(EXIT_FAILURE); \
    } while(0)


