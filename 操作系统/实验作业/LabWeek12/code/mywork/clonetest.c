#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sched.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/syscall.h>
#include <unistd.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <signal.h>

#define gettid() syscall(__NR_gettid)
#define gettidv2() syscall(SYS_gettid)
#define STACK_SIZE 1024*1024

/*
mbuf: 		Memory Buffer is to test CLONE_VM
ftext/ftext2:	File Text is to test CLONE_FILES
*/


int fd = 0, fd2 = 0;

char path[80] = "./test/test.txt";
char path2[80] = "./test/test2.txt";

const char* space1 = "                            ";
const char* space2 = "                                                        ";

struct sigaction newact;

int ipc = 0, sig = 0, par = 0, single = 0; 
// 标识变量：分别表示参数含CLONE_NEWIPC、含CLONE_SIGHAND，参数含CLONE_PARENT，只创建单个子进程

int vm = 0, files = 0;
int val = 1; //让信号只执行一次

void my_handler(int signo)  // user signal handler
{
    printf("\n%ssignal catched: signo = %d\n", space2, signo);
    val = 0;
}

static int child_func1(void *arg)
{
	int ret = 0;
	
	// 打印 PID PPID TID
	printf("%spid: %d\n", space1, getpid());
	printf("%sppid: %d\n", space1, getppid());
    	printf("%stid: %ld\n", space1, gettid());
    	
    	// 测试 CLONE_NEWIPC
    	if(ipc == 1){
		char ipcpath[80] = "/proc/";
		char pidstr[80];
		sprintf(pidstr, "%d", getpid());
		strcat(ipcpath, pidstr);
		strcat(ipcpath, "/ns/");
		printf("%sipcpath: %s\n", space1, ipcpath);
		char command[80] = "ls -al ";
		strcat(command, ipcpath);
		printf("child1 ipc: %d\n",getpid());
		system(command);
	}
	
    	// 测试 CLONE_VM 
    	if(vm == 1 || ipc == 0){
	    	printf("\n%s----------TEST-CLONE_VM\n", space1);
	    	char *childmbuf = (char*)arg; 
	    	printf("%smbuf: %s\n", space1, childmbuf);    	
	    	sprintf(childmbuf, "changed by child1");
	    	sleep(1);
	    	printf("%smbuf: %s\n", space1, childmbuf);
    	}
    	
	//printf("%ssleeping...\n", space1);
	sleep(1);
	//printf("%swaking...\n", space1);

	// 测试 CLONE_FILES 不论是否CLONE_FILES都可以通过文件描述符打开文件，因为会复制一份文件描述附表
	if(files == 1 || ipc == 0){
		printf("\n%s-------TEST-CLONE_FILES\n", space1);
		char ftext1[80];
		lseek(fd, 0, SEEK_SET);
		ret = read(fd, ftext1, 80);
		if(ret <= 0){
			printf("%sftext: cannot read\n", space1);
		}
		else{
			printf("%sftext: %s", space1, ftext1);
		}
		
		// 测试 CLONE_FILES 2 该进程创建文件描述符，另一个进程使用该描述符读取
		printf("\n%s------TEST2-CLONE_FILES\n", space1);
		fd2 = open(path2, O_RDONLY, 0666);
		if(fd2 == -1){
			perror("open()");
			exit(1);
		}
		char ftext2[80];
		ret = read(fd2, ftext2, 80);
		if(ret == -1){
			perror("read()");
			exit(1);
		}
		printf("%screate fd2: %d\n", space1, fd2);
		printf("%sftext2: %s", space1, ftext2);
		sleep(2);
    	}
    	
    	// 测试 CLONE_SIGHAND
    	if(sig == 1){
		printf("\n%s-----TEST-CLONE_SIGHAND\n", space1);
		newact.sa_handler = my_handler; /* set the user handler */
		sigemptyset(&newact.sa_mask); /* clear the mask */
		sigaddset(&newact.sa_mask, SIGQUIT); /* sa_mask, set signo=3 (SIGQUIT:Ctrl+\) */
		newact.sa_flags = 0; /* default */

		printf("%snow catching ctrl+C\n",space1);

		ret = sigaction(SIGINT, &newact, NULL); /* register signo=2 (SIGINT:Ctrl+C) */
		if(ret == -1) {
			perror("sigaction()");
			exit(1);
		}
	}
	
	printf("%sterminated\n", space1);
    	return 0;
}

static int child_func2(void *arg)
{
	int ret = 0;
	
	// 打印 PID PPID TID
    	printf("%spid: %d\n", space2, getpid());
    	printf("%sppid: %d\n", space2, getppid());
    	printf("%stid: %ld\n", space2, gettid());
    	
    	// 测试 CLONE_NEWIPC
    	if(ipc == 1){
		char ipcpath[80] = "/proc/";
		char pidstr[80];
		sprintf(pidstr, "%d", getpid());
		strcat(ipcpath, pidstr);
		strcat(ipcpath, "/ns/");
		printf("%sipcpath: %s\n", space2, ipcpath);
		char command[80] = "ls -al ";
		strcat(command, ipcpath);
		printf("child2 ipc: %d\n",getpid());
		system(command);
	}
	
    	// 测试 CLONE_VM
    	if(vm == 1 || ipc == 0){
	    	printf("\n%s----------TEST-CLONE_VM\n", space2);
	    	char *childmbuf = (char*)arg; 
	    	printf("%smbuf: %s\n", space2, childmbuf);  	
	    	sprintf(childmbuf, "changed by child2");
	    	sleep(1);
	    	printf("%smbuf: %s\n", space2, childmbuf);
	}
    	
	//printf("%ssleeping...\n", space2);
	sleep(1);
	//printf("%swaking...\n", space2);

	// 测试 CLONE_FILES
	if(files == 1 || ipc == 0){
		printf("\n%s-------TEST-CLONE_FILES\n", space2);
		char ftext1[80];
		lseek(fd, 0, SEEK_SET);
		ret = read(fd, ftext1, 80);
		if(ret <= 0){
			printf("%sftext: cannot read\n", space2);
		}
		else{
			printf("%sftext: %s", space2, ftext1);
		}
		
		// 测试 CLONE_FILES 2 先休眠，使用另一进程创建的描述符读取
		printf("\n%s------TEST2-CLONE_FILES\n", space2);
		char ftext2[80];
		sleep(1);
		ret = lseek(fd2, 0, SEEK_SET);
		if(ret == -1){
			printf("%sftext2: cannot read\n", space2);
		}
		else{
			ret = read(fd2, ftext2, 80);
			if(ret > 0){
				printf("%sftext2: %s", space2, ftext2);
			}
		}
	}
	// 测试 CLONE_SIGHAND
	if(sig == 1){
		printf("%s-----TEST-CLONE_SIGHAND\n", space2);
		while(val){
			sleep(1);
		}
	}
	
	printf("%sterminated\n", space2);
    	return 0;
}

int main(int argc, char **argv){
	int ret = 0;
	
	// 设置clone()的flags
	unsigned long flags = SIGCHLD;
	for(int i = 0; i < argc; i++){
		if(!strcmp(argv[i], "parent")){ // tested by each ppid
			flags |= CLONE_PARENT;
			par = 1;
		}
		else if(!strcmp(argv[i], "vm")){ // tested by mbuf
			flags |= CLONE_VM;
			vm = 1;
		}
		else if(!strcmp(argv[i], "vfork")){ // tested by thread function's sequence
			flags |= CLONE_VFORK;
		}
		else if(!strcmp(argv[i], "files")){ // tested by fd and fd2, especially fd2
			flags |= CLONE_FILES;
			files = 1;
		}
		else if(!strcmp(argv[i], "sighand")){ // tested by specific block in child_func
			flags |= CLONE_VM; 
			// must also include CLONE_VM if CLONE_SIGHAND is used 
			flags |= CLONE_SIGHAND;
			sig = 1;
		}
		else if(!strcmp(argv[i], "newipc")){ // 需要设置特权CAP_SYS_ADMIN
			//flags |= CLONE_NEWIPC;
			ipc = 1;
		}
		else if(!strcmp(argv[i], "thread")){ // tested by pid ppid and tid, especially tid
			flags |= CLONE_VM;
			flags |= CLONE_SIGHAND; 
			// must include CLONE_SIGHAND if CLONE_THREAD is used
			flags |= CLONE_THREAD;
		}
		else if(!strcmp(argv[i], "single")){ // 只创建child1而不创建child2,用于CLONE_SIGHAND测试
			single = 1;
		}
	}
	
	char *stack1 = malloc(STACK_SIZE*sizeof(char));
	char *stack2 = malloc(STACK_SIZE*sizeof(char));
	if(!stack1 || !stack2){
		perror("malloc()");
		exit(1);
	}
	
	pid_t childtid1, childtid2;
	char mbuf[80];
	sprintf(mbuf,"init by parent");
	
	// 输出模块
	printf("parent                      childtid 1                  childtid 2             \n");
    	printf("=======================     =======================     =======================\n");
	printf("pid: %d\n",getpid());
	printf("ppid: %d\n",getppid());
	printf("mbuf: %s\n",mbuf);
	
	// 测试 CLONE_NEWIPC
	if(ipc == 1){
		char ipcpath[80] = "/proc/";
		char pidstr[80];
		sprintf(pidstr, "%d", getpid());
		strcat(ipcpath, pidstr);
		strcat(ipcpath, "/ns/");
		printf("ipcpath: %s\n", ipcpath);
		char command[80] = "ls -al ";
		strcat(command, ipcpath);
		printf("parent pid: %d\n",getpid());
		system(command);
	}
	
	// 创建文件描述符，用于测试CLONE_FILES
	fd = open(path, O_RDONLY, 0666);
	if(fd == -1){
		perror("open()");
		exit(1);
	}
	char ftext[80];
	ret = read(fd, ftext, 80);
	if(ret == -1){
		perror("read()");
		exit(1);
	}
	printf("create fd: %d\n",fd);
	printf("ftext: %s",ftext);
	
	// 创建两个子线程
	printf("cloning...\n");
	childtid1 = clone(child_func1, stack1 + STACK_SIZE, flags, mbuf);
	if(childtid1 == -1) {
        	perror("clone1()");
        	free(stack1);
		stack1 = NULL;
		free(stack2);
		stack2 = NULL;
        	exit(1);
    	}
    	
    	if(single == 0){
		childtid2 = clone(child_func2, stack2 + STACK_SIZE, flags, mbuf);
		if(childtid2 == -1) {
			perror("clone2()");
			free(stack1);
			stack1 = NULL;
			free(stack2);
			stack2 = NULL;
			exit(1);
	    	}
    	}
    	
    	if(par == 1){
    		sleep(10); // for CLONE_PARENT
    	}
    	
    	int status = 0;
    	waitpid(childtid1, &status, 0);
    	if(single == 0){
		waitpid(childtid2, &status, 0);
    	}
    	
    	printf("finish waiting\n");
    	printf("mbuf: %s\n",mbuf);
    	
    	
	
    	printf("terminated \n");

    	close(fd);
    	close(fd2);
	free(stack1);
	stack1 = NULL;
	free(stack2);
	stack2 = NULL;
	return 0;
}

