#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>
#include <sys/wait.h>

int i = 0;

static void *thread_worker(void *args)
{
    
    while (1) {
        printf("%d\n", i);
        /* will print '0' only, by thread_worker of parent main() */
        sleep(1);
    }

    pthread_exit(0);
}

int main(void)
{
    pthread_t ptid;
    pthread_create(&ptid, NULL, &thread_worker, NULL);

    pid_t pid = fork(); /* child duplicates parent's main thread only, without thread_worker */
    if(pid == 0){
        i = 1;
        printf("in child\n");
        system("ps -l -T"); /* parent process, thread_worker of parent, child process */ 

        exit (0) ;
    }

    wait(&pid);
    printf("in parent\n");
    system("ps -l -T");

    while (1) ;

    return 0;
}


