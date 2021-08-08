#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/wait.h>

int main(void)
{
    int count = 1;
    pid_t childpid, childpid2, terminatedid;
    
    childpid = fork(); /* child duplicates parent’s address space */
    if (childpid < 0) {
        perror("fork()");
        return EXIT_FAILURE;
    }
    
    childpid2 = fork(); /* child duplicates parent’s address space */
    if (childpid2 < 0) {
        perror("fork()");
        return EXIT_FAILURE;
    }
    else
        if (childpid == 0) { /* This is child pro */
            count++;
            printf("child pro pid = %d, count = %d (addr = %p)\n", getpid(), count, &count); 
            printf("child sleeping ...\n");
            sleep(5); /* parent wait() during this period */
            printf("\nchild waking up!\n");
        }
        else if (childpid2 == 0) { /* This is child pro */
            count++;
            printf("child2 pro pid = %d, count = %d (addr = %p)\n", getpid(), count, &count); 
            printf("child2 sleeping ...\n");
            sleep(10); /* parent wait() during this period */
            printf("\nchild2 waking up!\n");
        }
        else { /* This is parent pro */
            terminatedid = wait(0);
            printf("Parent pro pid = %d, terminated pid = %d, count = %d (addr = %p)\n", getpid(), terminatedid, count, &count);
        }
    printf("\nTesting point by %d\n", getpid()); /* executed first by child and then parent */
    return EXIT_SUCCESS;
}
