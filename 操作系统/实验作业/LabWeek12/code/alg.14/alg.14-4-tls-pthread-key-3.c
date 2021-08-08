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

static pthread_key_t tls_key; /* static global */
 
void print_msg(void);
static void *thread_func1(void *);
static void *thread_func2(void *);

struct msg_struct {
    char pos[80];
    char stuno[9];
    char stuname[20];
};

int main(void)
{
    pthread_t ptid1, ptid2; 

    pthread_key_create(&tls_key, NULL);
	
    printf("       msg1 -->>        stuno     stuname       msg2 -->>         stuno     stuname\n");
    printf(" ===================  =========  ========  ===================  =========  ========\n");

    pthread_create(&ptid1, NULL, &thread_func1, NULL);
    pthread_create(&ptid2, NULL, &thread_func2, NULL);

    pthread_join(ptid1, NULL);
    pthread_join(ptid2, NULL);

    pthread_key_delete(tls_key);
    return EXIT_SUCCESS; 
}

static void *thread_func1(void *args)
{
    struct msg_struct ptr[5]; /* in thread stack */
    printf("thread_func1: tid = %ld   ptr = %p\n", gettid(), ptr);

    pthread_setspecific(tls_key, ptr); /* binding its tls_key to address of ptr */
    for (int i =0; i<5; i++) {
        sprintf(ptr[i].pos, " ");
        sprintf(ptr[i].stuno, "        ");
        sprintf(ptr[i].stuname, "                   ");
    }
    sprintf(ptr[0].stuno, "18000001");
    sprintf(ptr[0].stuname, "Alex");
    sprintf(ptr[4].stuno, "18000005");
    sprintf(ptr[4].stuname, "Michael");
    print_msg(); /* thread_func1 and thread_fun2 call the same print_msg() */
    pthread_exit(0);
}

static void *thread_func2(void *args)
{
    struct msg_struct ptr[5]; /* in thread stack */
    printf("thread_func2: tid = %ld   ptr = %p\n", gettid(), ptr);

    pthread_setspecific(tls_key, ptr); /* binding its tls_key to address of ptr */

    for (int i = 0;  i < 5; i++) {
        sprintf(ptr[i].pos, "                                           ");
        sprintf(ptr[i].stuno, "        ");
        sprintf(ptr[i].stuname, "                   ");
    }
    sprintf(ptr[0].stuno, "19000001");
    sprintf(ptr[0].stuname, "Bob");
    sprintf(ptr[2].stuno, "19000003");
    sprintf(ptr[2].stuname, "John");
    print_msg(); /* thread_func1 and thread_fun2 call the same print_msg() */
    pthread_exit(0);
}


void print_msg(void)
{	
    int randomcount;

    struct msg_struct* ptr = (struct msg_struct *)pthread_getspecific(tls_key); /* ptr decided by call thread */
    printf("print_msg:    tid = %ld   ptr = %p\n", gettid(), ptr);

    for (int i = 1; i < 6; i++) {
        randomcount = rand() % 10000;
        for (int k =0; k < randomcount; k++) ;
        printf("%stid = %ld  i = %2d   %s  %*.*s\n", ptr->pos, gettid(), i, ptr->stuno, 8, 8, ptr->stuname);
        ptr++;
    }

    return;
}
