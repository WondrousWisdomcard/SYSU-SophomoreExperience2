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
#define gettidv2() syscall(SYS_gettid)
#define STACK_SIZE 1024*1024

const char* space1 = "                       ";
const char* space2 = "                                              ";

static int child_func1(void *arg)
{
    	char *childbuf = (char*)arg; 
    	printf("%sbuf: %s\n", space1, childbuf);
    	sleep(1);
    	
    	sprintf(childbuf, "from child1");
    	printf("%spid: %d\n", space1, getpid());
    	printf("%stid: %ld\n", space1, gettid());
	printf("%ssleeping...\n", space1);
	sleep(2);
	printf("%swaking...\n", space1);

    	return 0;
}

static int child_func2(void *arg)
{
    	char *childbuf = (char*)arg; 
    	printf("%sbuf: %s\n", space2, childbuf);
    	sleep(1);
    	
    	// 内存空间共享测试
    	sprintf(childbuf, "from child2");
    	printf("%spid: %d\n", space2, getpid());
    	printf("%stid: %ld\n", space2, gettid());
	printf("%ssleeping...\n", space2);
	sleep(2);
	printf("%swaking...\n", space2);

    	return 0;
}

int main(int argc, char **argv){

	// 设置clone的flags
	unsigned long flags = SIGCHLD;
	for(int i = 0; i < argc; i++){
		if(!strcmp(argv[i], "parent")){
			flags |= CLONE_PARENT;
		}
		else if(!strcmp(argv[i], "vm")){ // test from buf
			flags |= CLONE_VM;
		}
		else if(!strcmp(argv[i], "vfork")){ // test from thread function's sequence
			flags |= CLONE_VFORK;
		}
		else if(!strcmp(argv[i], "files")){
			flags |= CLONE_FILES;
		}
		else if(!strcmp(argv[i], "sighand")){
			flags |= CLONE_SIGHAND;
		}
		else if(!strcmp(argv[i], "newipc")){
			flags |= CLONE_NEWIPC;
		}
		else if(!strcmp(argv[i], "thread")){
			flags |= CLONE_THREAD;
		}
		else if(!strcmp(argv[i], "all")){
			flags |= CLONE_PARENT;
			flags |= CLONE_VM;
			flags |= CLONE_VFORK;
			flags |= CLONE_FILES;
			flags |= CLONE_SIGHAND;
			flags |= CLONE_NEWIPC;
			flags |= CLONE_THREAD;
		}
	}
	
	char *stack1 = malloc(STACK_SIZE*sizeof(char));
	char *stack2 = malloc(STACK_SIZE*sizeof(char));
	if(!stack1 || !stack2){
		perror("malloc()");
		exit(1);
	}
	
	pid_t childtid1, childtid2;
	char buf[12];
	sprintf(buf,"from parent");
	
	// 输出模块
	printf("parent                 childtid 1             childtid 2        \n");
    	printf("==================     ==================     ==================\n");
	printf("pid: %d\n",getpid());
	printf("buf: %s\n",buf);
	printf("cloning...\n");
	
	// 创建文件描述符，用于测试CLONE_FILES
	char path[80] = "./test/test.txt";
	int fd = open(path, O_RDONLY, 0666);
	
	
	// 创建两个子线程
	childtid1 = clone(child_func1, stack1 + STACK_SIZE, flags, buf);
	if(childtid1 == -1) {
        	perror("clone1()");
        	exit(1);
    	}
	childtid2 = clone(child_func2, stack2 + STACK_SIZE, flags, buf);
	if(childtid2 == -1) {
        	perror("clone2()");
        	exit(1);
    	}
    	
    	int status = 0;
    	
    	waitpid(childtid1, &status, 0);
	waitpid(childtid2, &status, 0);
    	
    	printf("waiting... \n");
    	sleep(1);
    	printf("buf: %s\n\n",buf);
    	
    	
    	
    	
    	//system("ps");
    	
	free(stack1);
	stack1 = NULL;
	free(stack2);
	stack2 = NULL;
	return 0;
}


/*
CLONE_FILES (since Linux 2.0)
              If CLONE_FILES is set, the calling process and the child process
              share the same file descriptor table.  Any file descriptor  cre‐
              ated  by  the  calling  process  or by the child process is also
              valid in the other process.  Similarly, if one of the  processes
              closes a file descriptor, or changes its associated flags (using
              the fcntl(2) F_SETFD operation), the other process is  also  af‐
              fected.   If a process sharing a file descriptor table calls ex‐
              ecve(2), its file descriptor table is duplicated (unshared).

              If CLONE_FILES is not set, the child process inherits a copy  of
              all  file  descriptors opened in the calling process at the time
              of the clone call.  Subsequent operations  that  open  or  close
              file  descriptors, or change file descriptor flags, performed by
              either the calling process or the child process  do  not  affect
              the  other process.  Note, however, that the duplicated file de‐
              scriptors in the child refer to the same open file  descriptions
              as  the  corresponding  file descriptors in the calling process,
              and thus share file offsets and file status flags (see open(2)).
*/
