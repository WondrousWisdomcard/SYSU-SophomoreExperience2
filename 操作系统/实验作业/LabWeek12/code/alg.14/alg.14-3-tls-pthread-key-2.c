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
#include <malloc.h>
#include <pthread.h>
#define gettid() syscall(__NR_gettid)

static pthread_key_t tls_key; /* static global */
 
void print_msg1(void);
void print_msg2(void);
static void *thread_func1(void *);
static void *thread_func2(void *);

/* msg1 and mag2 have different structures */
struct msg_struct1 {
    char stuno[9];
    char stuname[20];
};
struct msg_struct2 {
    int stuno;
    char nationality[20];
    char stuname[20];
};

int main(void)
{
    pthread_t ptid1, ptid2; 

    pthread_key_create(&tls_key, NULL);
	
    printf("      msg1 -->>        stuno     stuname       msg2 -->>         stuno     stuname  nationaluty\n");
    printf("===================  =========  ========  ===================  =========  ========  ============\n");

    pthread_create(&ptid1, NULL, &thread_func1, NULL);
    pthread_create(&ptid2, NULL, &thread_func2, NULL);

    pthread_join(ptid1, NULL);
    pthread_join(ptid2, NULL);

    pthread_key_delete(tls_key);
    return EXIT_SUCCESS; 
}

static void *thread_func1(void *args)
{
    struct msg_struct1 ptr[5]; /* local variable in thread stacke */
    printf("thread_func1: tid = %ld   ptr = %p\n", gettid(), ptr);

    pthread_setspecific(tls_key, ptr); /* binding ptr to the tls_key */

    sprintf(ptr[0].stuno, "18000001");
    sprintf(ptr[0].stuname, "Alex");
    sprintf(ptr[4].stuno, "18000005");
    sprintf(ptr[4].stuname, "Michael");
    print_msg1();

    pthread_exit(0);
}

void print_msg1(void)
{	
    int randomcount;

    struct msg_struct1 *ptr = (struct msg_struct1 *)pthread_getspecific(tls_key);
    printf("print_msg1:   tid = %ld   ptr = %p\n", gettid(), ptr); 
	    /* sharing storage with thread_func1 */ 

    for (int i = 1; i < 6; i++) {
        randomcount = rand() % 10000;
        for (int k =0; k < randomcount; k++) ;
        printf("tid = %ld  i = %2d   %s  %*.*s\n", gettid(), i, ptr->stuno, 8, 8, ptr->stuname);
        ptr++;
    }
    
    return;
}
 
static void *thread_func2(void *args)
{
    struct msg_struct2 *ptr;
    ptr = (struct msg_struct2 *)malloc(5*sizeof(struct msg_struct2)); /* storage in process heap */
    printf("thread_func2: tid = %ld   ptr = %p\n", gettid(), ptr); 

    pthread_setspecific(tls_key, ptr);

    ptr->stuno = 19000001;
    sprintf(ptr->stuname, "Bob");
    sprintf(ptr->nationality, "United Kingdom");
    (ptr+2)->stuno = 19000003;
    sprintf((ptr+2)->stuname, "John");
    sprintf((ptr+2)->nationality, "United States");
    print_msg2();

    free(ptr);
    ptr = NULL;

    pthread_exit(0);
}

void print_msg2(void)
{	
    int randomcount;
    struct msg_struct2* ptr = (struct msg_struct2 *)pthread_getspecific(tls_key);
    printf("print_msg2:   tid = %ld   ptr = %p\n", gettid(), ptr);

    for (int i = 1; i < 6; i++) {
        randomcount = rand() % 10000;
        for (int k =0; k < randomcount; k++) ;
        printf("                                          tid = %ld  i = %2d   %d  %*.*s   %s\n", gettid(), i, ptr->stuno, 8, 8, ptr->stuname, ptr->nationality);
        ptr++;
    }
    
    return;
}
 
