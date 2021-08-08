#define SIZE 40  
#define NUM 200  
       
#define ACCESSIBLE 0
#define BLOCKED 1

#define ALIVED 0
#define DELETED 1

// 共享内存中共享单元的结构-(flag,学号,姓名)
struct shared_cell{
	int flag; // ALIVED or DELETED
	int id;
	char name[SIZE];
};

// 共享内存结构
struct shared_struct {
	int mode; // ACCESSIBLE or BLOCKED
	struct shared_cell heap[NUM + 1];  
	int size;
	
};

#define PERM S_IRUSR|S_IWUSR|IPC_CREAT

#define ERR_EXIT(m) \
    do { \
        perror(m); \
        exit(EXIT_FAILURE); \
    } while(0)


