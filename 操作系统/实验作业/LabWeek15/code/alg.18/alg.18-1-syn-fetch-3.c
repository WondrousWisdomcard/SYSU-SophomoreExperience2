#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#define MAX_N 40
static int count = 0;

void *test_func(void *arg)
{
    for (int i = 0; i < 20000; ++i)
//        __sync_fetch_and_add(&count, 1);
        count++; /* gave a wrong result */ 
    return NULL;
}

int main(void)
{
    pthread_t ptid[MAX_N];
    int i;

    for (i = 0; i < MAX_N; ++i)
         pthread_create(&ptid[i], NULL, &test_func, NULL);

    for (i = 0; i < MAX_N; ++i)
        pthread_join(ptid[i], NULL);
    printf("result conut = %d\n", count);

    return 0;
}

