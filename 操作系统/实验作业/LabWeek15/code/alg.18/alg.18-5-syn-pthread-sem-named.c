#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <semaphore.h>
#include <string.h>
#include <fcntl.h>
//#include <unistd.h>
#define MAX_N 40

sem_t *named_sem; /* a pointer */

static int count = 0;

void *test_func_syn(void *arg)
{
    for (int i = 0; i < 20000; ++i) {
        sem_wait(named_sem);
        count++;
        sem_post(named_sem);
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

    named_sem = sem_open("MYSEM", O_CREAT, 0666, 1); 
    /* a file named "sem.MYSEM" is created in /dev/shm/ to be shared by processes who know the file name */
    if (named_sem == SEM_FAILED) {
        perror("sem_open()");
        return EXIT_FAILURE;
    }

    if (argc > 1 && !strncmp(argv[1], "syn", 3))
        for (i = 0; i < MAX_N; ++i)
             pthread_create(&ptid[i], NULL, &test_func_syn, NULL);
    else 
        for (i = 0; i < MAX_N; ++i)
             pthread_create(&ptid[i], NULL, &test_func_asy, NULL);

    for (i = 0; i < MAX_N; ++i) {
        pthread_join(ptid[i],NULL);
    }

    printf("result count = %d\n", count);

    sem_close(named_sem);

    sem_unlink("MYSEM"); /* remove sem.MYSEM from /dev/shm/ when its references is 0 */
    
    return 0;
}

