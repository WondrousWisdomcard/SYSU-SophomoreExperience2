#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>

int i = 0;

static void *thread_worker(void *args)
{
    pid_t pid = fork(); /* the forked child takes thread_worker as main thread. This may cause unexpect behaviours in synchronization or signal handling */

    if(pid < 0 ) {
        return (void *)EXIT_FAILURE;
    }

    if(pid == 0) { /* child pro */
        i = 1;
        printf("in thread_worker's forked child\n");
        system("ps -l -T | grep a.out");
    }

    sleep(2);

    while (1) {
        printf("%d\n", i); 
        /* will print '0' by thread_worker of parent main(); '1' by forked child pro */
        sleep(2);
    }
    
    pthread_exit(0);
}

int main(void)
{
    pthread_t ptid;
    pthread_create(&ptid, NULL, &thread_worker, NULL);

    sleep(2) ;
    printf("in start main()\n");
    system("ps -l -T | grep a.out");

    //return 1; /* what will happen? you may have to pkill the forked child process */

    while (1) ;

    pthread_join(ptid, NULL);

    return EXIT_SUCCESS;
}

