#define TEXT_SIZE 40  /* = PAGE_SIZE, size of each message */
#define TEXT_NUM 20    /* maximal number of mesages */
    /* total size can not exceed current shmmax,
       or an 'invalid argument' error occurs when shmget */
# define WRITE 0
# define READ 1
# define READEND -1
struct shared_cell{
	int id;
	char name[TEXT_SIZE];
};

/* a demo structure, modified as needed */
struct shared_struct {
    int mode; // 1 is read and 0 is write
    int head; // shared_cell[head] is empty while shared_cell[(head-1)/TEXT_NUM] is the lastest node
    int tail; // shared_cell[tail] is the earliest node
    struct shared_cell cell[TEXT_NUM + 1]; // buffer for message reading and writing
};


#define PERM S_IRUSR|S_IWUSR|IPC_CREAT

#define ERR_EXIT(m) \
    do { \
        perror(m); \
        exit(EXIT_FAILURE); \
    } while(0)


