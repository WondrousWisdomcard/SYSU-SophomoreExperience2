/* gcc -pthread
1. int pthread_key_create(pthread_key_t *key, void (*destructor)(void*));
2. int pthread_setspecific(pthread_key_t key, const void *value);
3. void *pthread_getspecific(pthread_key_t key);
4. int pthread_key_delete(pthread_key_t key);
*/

#include <stdio.h>
#include <stdlib.h>
#include <sys/syscall.h>
#include <unistd.h>
#include <pthread.h>
#define gettid() syscall(__NR_gettid)

static pthread_key_t log_key;
    /* each thread associates the static global log_key with one local variable of the thread */
    /* the associated local variable behaves like a global variable by making use of log_key */
 
void write_log(const char *msg)
{	
    FILE *fp_log;
    fp_log = (FILE *)pthread_getspecific(log_key); /* fp_log is shared in the same thread */
    fprintf(fp_log, "writing msg: %s\n", msg);
    printf("log_key = %d, tid = %ld, address of fp_log %p\n", log_key, gettid(), fp_log);
}
 
static void *thread_worker(void *args)
{
    static int thcnt = 0;
    char fname[64], msg[64];
    FILE *fp_log; /* a local variable */
	
    sprintf(fname, "log/thread-%d.log", ++thcnt);  /* directory ./log must exist */
    fp_log = fopen(fname, "w");
    if(!fp_log) {
        printf("%s\n", fname);
        perror("fopen()");
        return NULL;
    }

    pthread_setspecific(log_key, fp_log); /* fp_log is associated with log_key */
 
    sprintf(msg, "Here is %s\n", fname);
    write_log(msg);
}

void close_log_file(void* log_file) /* the destructor */
{
    fclose((FILE*)log_file);
}

int main(void)
{
    const int n = 5; 
    pthread_t tids[n]; 
    pthread_key_create(&log_key, &close_log_file);
// or:    pthread_key_create(&log_key, NULL); /* NULL for default destructor */
	
    printf("======tids and TLS variable addresses ======\n");
    for (int i = 0; i < n; i++) {
        pthread_create(&tids[i], NULL, &thread_worker, NULL);
    }
	
    for (int i = 0; i < n; i++) {
        pthread_join(tids[i], NULL);
    }
	
    pthread_key_delete(log_key); /* deletey the key */

    printf("\ncommand: lsof +d ./log\n");
    system("lsof +d ./log"); /* list all open instance of directory ./log */
    printf("\ncommand: cat ./log/thread-1.log ./log/thread-5.log\n");
    system("cat ./log/thread-1.log ./log/thread-5.log");

    return 0; 
}

