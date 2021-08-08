#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/wait.h>

int main(void)
{
    int count = 1;
    pid_t childpid;
    
    childpid = vfork(); /* child shares parent’s address space */
    if (childpid < 0) {
        perror("fork()");
        return EXIT_FAILURE;
    }
    else /* vfork() returns 2 values: 0 for child pro and childpid for parent pro */
        if (childpid == 0) { /* This is child pro, parent hung up until child exit ...  */
            count++;
            printf("Child pro pid = %d, count = %d (addr = %p)\n", getpid(), count, &count); 
            printf("Child taking a nap ...\n");
            sleep(5);
            printf("Child waking up!\n");
            _exit(0); /* or exec(0); "return" will cause stack smashing */
        }
        else { /* This is parent pro, start when the vforked child finished */
            printf("Parent pro pid = %d, child pid = %d, count = %d (addr = %p)\n", getpid(), childpid, count, &count);
            wait(0); /* not waitting this vforked child terminated*/
        }
    printf("Testing point by %d\n", getpid()); /* executed by parent pro only */
    return EXIT_SUCCESS;
}
