#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <string.h>
#define MAX_N 40

static int count = 0;
pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
/*  pthread_mutex_t mutex; */

void *test_func_syn(void *arg)
{
    for (int i = 0; i < 20000; ++i) {
        pthread_mutex_lock(&mutex);
        count++;
        pthread_mutex_unlock(&mutex);
    }

    pthread_exit(NULL);
}

void *test_func_asy(void *arg)
{
    for (int i = 0; i < 20000; ++i) {
        count++;
    }

    pthread_exit(NULL);
}

int main(int argc, const char *argv[])
{
    int i = 0;
    pthread_t ptid[MAX_N];

//    pthread_mutex_init (&mutex, NULL);

    if(argc > 1 && !strncmp(argv[1], "syn", 3))
        for (i = 0; i < MAX_N; ++i)
             pthread_create(&ptid[i], NULL, &test_func_syn, NULL);
    else 
        for (i = 0; i < MAX_N; ++i)
             pthread_create(&ptid[i], NULL, &test_func_asy, NULL);

    for (i = 0; i < MAX_N; ++i) {
        pthread_join(ptid[i], NULL);
    }

    pthread_mutex_destroy(&mutex);

    printf("result count = %d\n", count);
    return 0;
}

