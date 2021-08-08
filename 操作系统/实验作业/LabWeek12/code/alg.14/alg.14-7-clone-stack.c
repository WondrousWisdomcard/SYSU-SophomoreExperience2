#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <sched.h>
#include <sys/wait.h>
#include <unistd.h>
#include <sys/syscall.h>

#define gettid() syscall(__NR_gettid)
#define STACK_SIZE (524288-10000)*4096 /* 2^19 = 524288 */

static int test(void *arg)
{ 
    static int i = 0;
    char buffer[1024]; 
    if(i == 0) {
        printf("test: my ptd = %d, tid = %ld, ppid = %d\n", getpid(), gettid(), getppid());
        printf("\niteration = %8d", i); 
    }
    printf("\b\b\b\b\b\b\b\b%8d", i); 
    i++; 
    test(arg); /* recursive calling */
}     
    
int main(int argc,char **argv)
{
    char *stack = malloc(STACK_SIZE); /* allocating from heap */
    pid_t chdtid;
    char buf[40];

    if(!stack) {
        perror("malloc()");
        exit(1);
    }
    
    unsigned long flags = 0;
      /* creat child thread */
    chdtid = clone(test, stack + STACK_SIZE, flags | SIGCHLD, buf);
      /* top of child stack is stack+STACK_SIZE; main thread and test thread work cocurrently */
    if(chdtid == -1) {
        perror("clone()");
    }
   
    printf("\nmain: my pid = %d, I'm waiting for cloned child, his tid = %d\n", getpid(), chdtid);
 
    int status = 0;
    int ret;
    
    ret = waitpid(-1, &status, 0); /* wait for any child existing */
    if(ret == -1) {
        perror("waitpid()");
    }

    sleep(2);
    printf("\nmain: my pid = %d, waitpid returns = %d\n", getpid(), ret);

    free(stack);
    stack = NULL;

    return 0;
}

