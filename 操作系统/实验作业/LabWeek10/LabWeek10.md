[toc]

## POSIX Pthreads

0. 库函数说明：

	```
	#include <stdio.h>
	#include <stdlib.h>
	#include <pthread.h>
	/*编译器选项： gcc -lpthread | -pthread */
	```

1. ```pthread_create```：用于创建一个线程

	* 它的功能是创建线程，在线程创建以后，就开始运行相关的线程函数。 
	* 函数原型：
		```
		int pthread_create(
             pthread_t *restrict tidp,   //新创建的线程ID指向的内存单元。
             const pthread_attr_t *restrict attr,  //线程属性，默认为NULL
             void *(*start_rtn)(void *), //新创建的线程从start_rtn函数的地址开始运行
             void *restrict arg //默认为NULL。若上述函数需要参数，将参数放入结构中并将地址作为arg传入。
        );
		```
	* 需要注意的问题：
		1.传递参数注意的问题：
			* 避免直接在传递的参数中传递发生改变的量，否则会导致结果不可测。 
			* 通常的解决方案是：重新申请一块内存，存入需要传递的参数，再将这个地址作为arg传入。
		2.使用时注意防止内存泄漏：
			* 在默认情况下通过```pthread_create```函数创建的线程是非分离属性的，由pthread_create函数的第二个参数决定，在非分离的情况下，当一个线程结束的时候，它所占用的系统资源并没有完全真正的释放，也没有真正终止。
			* 只有在pthread_join函数返回时，该线程才会释放自己的资源。
			* 或者是设置在分离属性的情况下，一个线程结束会立即释放它所占用的资源。

2. ```pthread_exit```：终止线程
	* 函数原型：```void pthread_exit __P ((void *__retval)) __attribute__ ((__noreturn__));```
	
3. ```pthread_join```：让该线程进入等待状态，等待另一个线程

	* 函数原型“```int pthread_join __P ((pthread_t __th, void **__thread_return));```
	* 第二个参数为一个用户定义的指针，它可以用来存储被等待线程的返回值，这个值地1创建是可以在线程中```malloc```的。
	* 该函数会一直阻塞调用线程，直到指定的线程终止。当```pthread_join()```返回之后，应用程序可回收与已终止线程关联的任何数据存储空间。 
	* 这个函数是一个线程阻塞的函数，调用它的线程将一直等待到被等待的线程结束为止，当函数返回时，被等待线程的资源被收回。一个线程的结束有两种途径，一种是函数结束了，调用它的线程也就结束了；另一种方式是通过函数pthread_exit来实现。
	* 一个线程不能被多个线程等待，否则第一个接收到信号的线程成功返回，其余调用pthread_join的线程则返回错误代码ESRCH。
	* **pthread_join用于等待一个线程的结束，也就是主线程中要是加了这段代码，就会在加代码的位置卡主，直到这个线程执行完毕才往下走。**
	* **pthread_exit用于强制退出一个线程（非执行完毕退出），一般用于线程内部。**
4. ```pthread_yield```：释放CPU资源以让别的进程运行

5. ```pthread_attr_init```：创建，初始化一个线程的属性

6. ```pthread_attr_destory```：删除一个线程的属性

* 其他细节函数：

	1. ```int main(int argc, char *argv[]);```,注意使用argc（参数个数），argv（一个存程序输入的字符串数组，第一个传进去的参数是在argv[1]）。
	
	2. ```perror("pthread_create()");```
	
	3. ```static void *runner(void *);```，线程调用函数的格式，定义。
	
	4. ```pthread_self()```，返回线程自身的ptid。，输出格式遵循是```%lu```。
	
	5. ```pthread_setstack()```，用于为一个线程指定栈空间，参数是ptid，栈指针，栈大小。
	
	6. ```pthread_cancel(ptid);```
	
	7. **需要注意变量类型的转换，因为在函数参数中要求的都是void类型的指针，但实际在根据地址取值时需要先转换类型。**
	
	8. 我看都是一般create后，就马上join了。
## 计时
```
#include <sys/time.h>
#include <ctype.h>

long start_us, end_us;
struct timeval t;
gettimeofday(&t, 0);
start_us = (long)(t.tv_sec * 1000 * 1000) + t.tv_usec;


gettimeofday(&t, 0);
end_us = (long)(t.tv_sec * 1000 * 1000) + t.tv_usec;
printf("Overhead time usec = %ld, with no omp\n", end_us-start_us);	
```
## 程序随便跑跑

1. pthread-create ：介绍了创建单个pthread的步骤，**两变量两函数**。	

	```
    pthread_t ptid; /* thread identifier */
    pthread_attr_t attr; /* thread attributes structure */
    pthread_attr_init(&attr); /* set the default attributes */

      /* create the thread - runner with argv[1] */
    ret = pthread_create(&ptid, &attr, &runner, argv[1]);
    if(ret != 0) {
        perror("pthread_create()");
        return 1;
    }
	```

2. pthread-create-1-1：阐述了一种线程内往线程外传输数据的方法：**主函数使用pthread_join等待创建的线程，并且该函数带入一个void指针类型变量（第二个参数），线程通过malloc创建一个变量再将其地址通过pthread_exit返回该变量的指针。**主函数最后记得free。

3. pthread-create-1-2：阐述了一种线程内往线程外传输数据的方法：**主函数使用pthread_join等待创建的线程，并且该函数带入一个void指针类型变量（第二个参数），这个变量指向静态数据域的变量，线程通过pthread_exit返回该变量的指针，指针能够正确指向对应的静态数据。**

4. pthread-create-1-3：针对join第二个参数指向的数据，是在主函数内声明的也行。

5. pthread-create-2：对于全局变量，线程可改并更新，非全局变量则需要通过指向他的指针传入，返回。

6. pthread-create-3：该实验展示了由 传入作各线程变量（传址） 且 被用作与遍历线程数组 的变量 在多线程上时 发生的 线程输出在系统上的结果的混乱。不同线程传入的地址指向的变量相同，不同线程使用修改该变量，造成冲突，使得线程输出在系统上的结果是混乱的。

7. pthread-create-3-1：在上一个实验的基础上，创建线程后休眠一秒，让各线程**异步**使用可共同访问、影响的变量，避免冲突。

8. pthread-create-4：对上上一个实验进行改进，让各个线程需要访问的数据不再一个变量里，而是每个线程需调用的问题在数组的专门一个位置上，避免冲突。**这是一个值得学习的设计方法**，不保证时序，但保证不出现错位。

9. pthread-shm：我觉得实在测试join函数有效。

10. 加入了pthread_setstack函数，用于为一个线程指定栈空间。
	

