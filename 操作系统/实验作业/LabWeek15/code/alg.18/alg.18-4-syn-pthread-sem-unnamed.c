#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <semaphore.h>
#include <string.h>
#define MAX_N 40

sem_t unnamed_sem;

static int count = 0;

void *test_func_syn(void *arg)
{
    for (int i = 0; i < 20000; ++i) {
        sem_wait(&unnamed_sem);
        count++;
        sem_post(&unnamed_sem);
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
    pthread_t ptid[MAX_N];
    int i, ret;

    ret = sem_init(&unnamed_sem, 0, 1); /* initialize an unnamed semaphore for thread communication */
    if(ret == -1) {
        perror("sem_init()");
        return EXIT_FAILURE;
    }
    
    if(argc > 1 && !strncmp(argv[1], "syn", 3))
        for (i = 0; i < MAX_N; ++i)
             pthread_create(&ptid[i], NULL, &test_func_syn, NULL);
    else 
        for (i = 0; i < MAX_N; ++i)
             pthread_create(&ptid[i], NULL, &test_func_asy, NULL);

    for (i = 0; i < MAX_N; ++i) {
        pthread_join(ptid[i],NULL);
    }

    printf("result count = %d\n", count);

    sem_destroy(&unnamed_sem);

    return 0;
}

