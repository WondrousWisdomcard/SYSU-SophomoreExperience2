#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>
// #include <sys/wait.h>

int main(void)
{
    int count = 1;
    pid_t childpid;
    
    childpid = fork(); /* child duplicates parent’s address space */
    if (childpid < 0) {
        perror("fork()");
        return EXIT_FAILURE;
    }
    else
        if (childpid == 0) { /* This is child pro */
            count++;
            printf("child pro pid = %d, count = %d (addr = %p)\n", getpid(), count, &count); 
            printf("child sleeping ...\n");
            sleep(10); /* parent exites during this period and child became an orphan */
            printf("\nchild waking up!\n");
        }
        else { /* This is parent pro */
            printf("Parent pro pid = %d, child pid = %d, count = %d (addr = %p)\n", getpid(), childpid, count, &count);
        }
    printf("\nTesting point by %d\n", getpid()); /* executed both by parent and child */
    return EXIT_SUCCESS;
}
