#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sched.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/syscall.h>
#include <unistd.h>
#define gettid() syscall(__NR_gettid)
  /* wrap the system call syscall(__NR_gettid), __NR_gettid = 224 */
#define gettidv2() syscall(SYS_gettid) /* a traditional wrapper */

#define STACK_SIZE 1024*1024 /* 1Mib. question: what is the upperbound of STACK_SIZE */

static int child_func1(void *arg)
{
    char *chdbuf = (char*)arg; /* type casting */
    printf("child_func1 read buf: %s\n", chdbuf);
    sleep(1);
    sprintf(chdbuf, "I am child_func1, my tid = %ld, pid = %d", gettid(), getpid());
    printf("child_func1 set buf: %s\n", chdbuf);
    sleep(1);
    printf("child_func1 sleeping and then exists ...\n");
    sleep(1);

    return 0;
}

static int child_func2(void *arg)
{
    char *chdbuf = (char*)arg; /* type casting */
    printf("child_func2 read buf: %s\n", chdbuf);
    sleep(1);
    sprintf(chdbuf, "I am child_func2, my tid = %ld, pid = %d", gettid(), getpid());
    printf("child_func2 set buf: %s\n", chdbuf);
    sleep(1);
    printf("child_func2 sleeping and then exists ...\n");
    sleep(1);

    return 0;
}

int main(int argc,char **argv)
{
    char *stack1 = malloc(STACK_SIZE*sizeof(char)); /* allocating from heap, safer than stack1[STACK_SIZE] */
    char *stack2 = malloc(STACK_SIZE*sizeof(char));
    pid_t chdtid1, chdtid2;
    unsigned long flags = 0;
    char buf[100]; /* a global variable has the same behavior */

    if(!stack1 || !stack2) {
        perror("malloc()");
        exit(1);
    }
    
      /* set CLONE flags */
    if((argc > 1) && (!strcmp(argv[1], "vm"))) {
        flags |= CLONE_VM;
    }
    if((argc > 2) && (!strcmp(argv[2], "vfork"))) {
        flags |= CLONE_VFORK;
    }

    sprintf(buf,"I am parent, my pid = %d", getpid());
    printf("parent set buf: %s\n", buf);
    sleep(1);
    printf("parrent clone ...\n");
    
      /* creat child thread, top of child stack is stack+STACK_SIZE */
    chdtid1 = clone(child_func1, stack1 + STACK_SIZE, flags | SIGCHLD, buf); /* what happened if without SIGCHLD */
    if(chdtid1 == -1) {
        perror("clone1()");
        exit(1);
    }

    chdtid2 = clone(child_func2, stack2 + STACK_SIZE, flags | SIGCHLD, buf);
    if(chdtid2 == -1) {
        perror("clone2()");
        exit(1);
    }

    printf("parent waiting ... \n");

    int status = 0;
    if(waitpid(-1, &status, 0) == -1) { /* wait for any child existing, may leave some child defunct */
        perror("wait()");
    }
  
//waitpid(chdtid1, &status, 0);
//waitpid(chdtid2, &status, 0);
  
    sleep(1);

    printf("parent read buf: %s\n", buf);

    system("ps");
    
    free(stack1);
    free(stack2);
    stack1 = NULL;
    stack2 = NULL;

    return 0;
}

