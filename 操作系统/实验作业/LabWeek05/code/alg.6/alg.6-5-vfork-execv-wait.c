#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/stat.h>
#include <wait.h>

int main(int argc, char* argv[])
{
    pid_t childpid;

    childpid = vfork();
        /* child shares parent's address space */
    if (childpid < 0) {
        perror("fork()");
        return EXIT_FAILURE;
    }
    else
        if (childpid == 0) { /* This is child pro */
            printf("This is child, pid = %d, taking a nap for 2 seconds ...\n", getpid());
            sleep(2); /* parent hung up and do nothing */

            char filename[80];
            struct stat buf;
            strcpy(filename, "./alg.6-5-0-sleeper.o");
            if(stat(filename, &buf) == -1) {
                perror("\nsleeper stat()");
                _exit(0);
            }
            char *argv1[] = {filename, argv[1], NULL};
            printf("child waking up and again execv() a sleeper: %s %s\n\n", argv1[0], argv1[1]); 
            execv(filename, argv1);
/* parent resume at the point 'execv' called. The vforked pro terminated and alg.6-5-sleeper.o spawned as child in the same childpid but with duplicated address space and returns to parent without any stack smashing. parent and child execute asynchronously */
        }
        else { /* This is parent pro, start when the vforked child terminated */
            printf("This is parent, pid = %d, childpid = %d \n", getpid(), childpid);
                /* parent executed this statement during the EXECV time */
            int retpid = wait(0); 
                /* without wait(), the spawned EXECV may became an orphan */
            printf("\nwait() returns childpid = %d\n", retpid);
        }
        
    return EXIT_SUCCESS;
}

