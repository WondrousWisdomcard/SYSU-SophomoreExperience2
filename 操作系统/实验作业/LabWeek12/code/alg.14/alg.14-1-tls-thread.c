#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/syscall.h>
#include <pthread.h>

#define gettid() syscall(__NR_gettid) 

__thread int tlsvar = 0; 
 /* tlsvar for each thread; interpreted by language compiler,
    a language level solution to thread local storage */

static void* thread_worker(void* arg)
{  
    char *param = (char *)arg; 
    int randomcount;

    for (int i = 0; i < 5; ++i) {
        randomcount = rand() % 100000;
        for (int k = 0; k < randomcount; k++) ;
        printf("%s%ld, tlsvar = %d\n", param, gettid(), tlsvar);
        tlsvar++; /* each thread has its local tlsvar */
    }
    
    pthread_exit(0);

}  

int main(void)
{
    pthread_t tid1, tid2;  
    char para1[] = "                     ";
    char para2[] = "                                          ";
    int randomcount;

    pthread_create(&tid1, NULL, &thread_worker, para1);  
    pthread_create(&tid2, NULL, &thread_worker, para2);  
    
    printf("parent               tid1                 tid2\n");
    printf("================     ================     ================\n");

    for (int i = 0; i < 5; ++i) {
        randomcount = rand() % 100000;
        for (int k = 0; k < randomcount; k++) ;
        printf("%ld, tlsvar = %d\n", gettid(), tlsvar);
        tlsvar++; /* main- thread has its local tlsvar */
    }

    sleep(1);
    pthread_join(tid1, NULL);  
    pthread_join(tid2, NULL);  

    return 0;  
}
  
