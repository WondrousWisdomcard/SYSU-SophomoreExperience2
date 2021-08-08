#include <stdio.h>
#include <stdlib.h>
#include <sys/syscall.h>
#include <unistd.h>
#include <malloc.h>
#include <pthread.h>
#define gettid() syscall(__NR_gettid)

static pthread_key_t tls_key; /* static global */
 
static void *thread_func(void *);
void thread_data1(void);
void thread_data2(void);

struct msg_struct {
    char stuno[9];
    char stuname[20];
};

int main(void)
{
    pthread_t ptid;

    pthread_key_create(&tls_key, NULL);
    pthread_create(&ptid, NULL, &thread_func, NULL);
    pthread_join(ptid, NULL);
    pthread_key_delete(tls_key);

    return EXIT_SUCCESS; 
}

static void *thread_func(void *args)
{
    struct msg_struct *ptr;

    thread_data1();
    ptr = (struct msg_struct *)pthread_getspecific(tls_key); /* get ptr from thread_data1() */
    perror("pthread_getspecific()");
    printf("ptr from thread_data1() in thread_func(): %p\n", ptr);
    for (int i = 1; i < 6; i++) {
        printf("tid = %ld  i = %2d   %s  %*.*s\n", gettid(), i, (ptr+i-1)->stuno, 8, 8, (ptr+i-1)->stuname);
    }

    thread_data2();
    ptr = (struct msg_struct *)pthread_getspecific(tls_key); /* get ptr from thread_data2() */
    perror("pthread_getspecific()");
    printf("ptr from thread_data2() in thread_func(): %p\n", ptr);
    for (int i = 1; i < 6; i++) {
        printf("tid = %ld  i = %2d   %s  %*.*s\n", gettid(), i, (ptr+i-1)->stuno, 8, 8, (ptr+i-1)->stuname);
    }

    free(ptr);
    ptr = NULL;

    pthread_exit(0);
}

void thread_data1(void)
{
    struct msg_struct ptr[5]; /* in thread stack */
    pthread_setspecific(tls_key, ptr); /* binding the tls_key to address of ptr */
    printf("ptr in thread_data1(): %p\n", ptr);

    for (int i = 0; i < 5; i++) {
        sprintf(ptr[i].stuno, "        ");
        sprintf(ptr[i].stuname, "                   ");
    }
    sprintf(ptr[0].stuno, "19000001");
    sprintf(ptr[0].stuname, "Bob");
    sprintf(ptr[2].stuno, "19000003");
    sprintf(ptr[2].stuname, "John");

    return;
    /* thread stack space is deallocated when thread_data1() returns and data lost */ 
}

void thread_data2(void)
{
    struct msg_struct *ptr;
    ptr = (struct msg_struct *)malloc(5*sizeof(struct msg_struct));  /* in process heap */
    pthread_setspecific(tls_key, ptr); /* binding the tls_key to address of ptr */
    printf("ptr in thread_data2(): %p\n", ptr);

    for (int i = 0; i < 5; i++) {
        sprintf(ptr[i].stuno, "        ");
        sprintf(ptr[i].stuname, "                   ");
    }
    sprintf(ptr->stuno, "19000001");
    sprintf(ptr->stuname, "Bob");
    sprintf((ptr+2)->stuno, "19000003");
    sprintf((ptr+2)->stuname, "John");

    return;
    /* the heap space is kept effective if ptr is not freed */
    /* if free(ptr) before return, the space is reallocated and data lost */
    /* need to free the space in thread_func or there is a memory leak */
}
