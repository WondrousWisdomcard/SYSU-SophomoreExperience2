/* matrix multiplication: without threads and with threads
   multithreading has a clear advantage when od > 80 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/time.h>
#include <ctype.h>
#include <pthread.h>
#define MAX_N 1024

int a[MAX_N][MAX_N], b[MAX_N][MAX_N];
int ans[MAX_N][MAX_N];
int od = 5;

static void *ftn(void *arg)
{
    int *s_addr = (int *)arg;
    int row_num = *s_addr;
  
    for (int j = 0; j < od; j++){
        ans[row_num][j] = 0;
        for (int k = 0; k < od; k++){
            ans[row_num][j] += a[row_num][k] * b[k][j];
        }
    }

    pthread_exit(0);
}
 
int main(int argc, char *argv[])
{
    int ret, sleep_sec = 0;
    
    if(argc > 1)
        od = atoi(argv[1]);
    if(od > MAX_N)
        return 1;
    
    for (int i = 0; i < od; i++) {
        for (int j = 0; j < od; j++) {
            a[i][j] = 20;
        }
    }
    for (int i = 0; i < od; i++) {
        for (int j = 0; j < od; j++) {
            b[i][j] = 30;
        }
    }

    int row_num[od];
    for (int i = 0; i < od; i++) {
        row_num[i] = i;
    }

    printf("main(): pid = %d, ptid = %lu.\n", getpid( ), pthread_self( ));

    long start_us, end_us;
    struct timeval t;

    gettimeofday(&t, 0);
    start_us = (long)(t.tv_sec * 1000 * 1000) + t.tv_usec;

    for (int i = 0; i < od; i++) {
        for (int j = 0; j < od; j++) {
            ans[i][j] = 0;
            for (int k = 0; k < od; k++) {
                ans[i][j] += a[i][k] * b[k][j];
            }
        }
    }

    gettimeofday(&t, 0);
    end_us = (long)(t.tv_sec * 1000 * 1000) + t.tv_usec;
    printf("ans[0][0] = %d\nrunning time without threads = %ld usec\nPress a key ...", ans[0][0], end_us - start_us);
    getchar();
    	    
    gettimeofday(&t, 0);
    start_us = (long)(t.tv_sec * 1000 * 1000) + t.tv_usec;

    pthread_t ptid[od];
    for (int i = 0; i < od; i++) {
        ret = pthread_create(&ptid[i], NULL, ftn, (void *)&row_num[i]);
        if(ret != 0) {
            fprintf(stderr, "pthread_create error: %s\n", strerror(ret));
            exit(1);
        }
    }

    for (int i = 0; i < od; i++) {
        ret = pthread_join(ptid[i], NULL);
        if(ret != 0) {
            fprintf(stderr, "pthread_join error: %s\n", strerror(ret));
            exit(1);
        }
    }

    gettimeofday(&t, 0);
    end_us = (long)(t.tv_sec * 1000 * 1000) + t.tv_usec;
    printf("ans[0][0] = %d\nrunning time with threads = %ld usec\nPress a key ...", ans[0][0], end_us - start_us);

    printf("Printing multithreading result? (y/n)");
    if(getchar() != 'y')
        return 1;

    for (int i = 0; i < od; i++){
        for (int j = 0; j < od; j++){
            printf("%d ", ans[i][j]);
        }
        putchar(10);
    } 

    return 1;
}

