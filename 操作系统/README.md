# Wondrouswisdomcard's OSLab

## AT&T汇编

### LabWeek02 - AT&T汇编学习01
* 验证实验 Blum’s Book: Sample programs in Chapter 04, 05 (Moving Data)
* Chapter04 - 基本汇编语言程序模板
* Chapter05 - 汇编语言处理数据

### LabWeek03 - AT&T汇编学习02
* 验证实验 Blum’s Book: Sample programs in Chapter 06, 07 (Controlling Flow and Using Numbers)
* Chapter06 - 控制执行流程（跳转和循环）
* Chapter07 - 不同的数字格式和使用方法

### LabWeek04 - AT&T汇编学习03
* 验证实验 Blum’s Book: Sample programs in Chapter 08, 10 (Basic Math Functions and Using Strings)
* Chapter08 - 基本数学功能
* Chapter10 - 字符串处理
## 进程

### LabWeek05 - 进程的创建和终止
1. 编译运行课件 Lecture 06 例程代码：Algorithms 6-1 ~ 6-6.（`fork`, `vfork`, `execv`的使用）

### LabWeek06 - 进程间通信 - 共享内存
1. 实验验证 Lecture 08 例程代码 8-1 ~ 8-3 和 8-4 ~ 8-5。
2. 设计：修改 8-1 ~ 8-3 程序将共享空间组织成一个循环队列来进行FIFO操作，采用共享内存队列控制队列数据的同步。
### LabWeek07 - 进程间通信 - 共享内存
* 实验内容: 实现一个带有 n 个单元的线性表的并发维护。
	1. 建立一个足够大的共享内存空间 (lock, M),逻辑值 lock 用来保证同一时间只有一个进程进入 M;测试你的系统上 M 的上限。
	2. 设计一个程序在 M 上建立一个结点信息结构为 (flag, 学号, 姓名) 的静态链表 L,逻辑值 flag 用作结点的删除标识;在 L 上建立一个以学号为关键字的二元小顶堆,自行设计控制结构 (如静态指针数据域)。
	3. 设计一个程序对上述堆结构的结点实现插入、删除、修改、查找、重
	排等操作。该程序的进程可以在多个终端并发执行。
	4. 思考:使用逻辑值 lock 实现的并发机制不能解决条件冲突问题。
### LabWeek08 - 进程间通信 - 消息机制
* 实验内容1: 进程间通信—消息机制。
	* 编译运行课件 Lecture 09 例程代码:
		* Algorithms 9-1 ~ 9-2.
		* 修改代码,观察在 msgsnd 和 msgrcv 并发执行情况下消息队列的变化情况。
* 实验内容2:
	* 仿照 alg.8-4~8-6,编制基于 POSIX API 的进程间消息发送和消息接收例程。
### LabWeek09 - 进程间通信 - 管道和socket通信
* 实验内容:进程间通信—管道和 socket 通信。
	* 编译运行课件 Lecture11 例程代码:
		* alg.11-3-socket-input-2.c
		* alg.11-4-socket-connector-BBS-2.c
		* alg.11-5-socket-server-BBS-3.c
## 线程

### LabWeek10 - 期中考试
* 考试内容：pthread实现多线程并行计算并计时。

### LabWeek11 - 线程(1) 
* 实验内容：线程(1) - POSIX API
    * 编译运行课件 Lecture13 例程代码：
        Algorithms 13-1 ~ 13-8.

### LabWeek12 - 线程(2)
* 实验内容:线程(2) - TLS 与 clone()
	* 编译运行课件 Lecture14 例程代码:
		* Algorithms 14-1 ~ 14-7.
	* 比较 pthread 和 clone() 线程实现机制的异同
	* 对 clone() 的 flags 采用不同的配置，**设计测试程序**讨论其结果
		* 配置包括 COLNE_PARENT, CLONE_VM, CLONE_VFORK, CLONE_FILES, CLONE_SIGHAND, CLONE_NEWIPC, CLONE_THREAD
### LabWeek13 - 线程池
* 实验内容:设计实现一个线程池 (Thread Pool)
	* 使用 Pthread API
	* FIFO
	* 先不考虑互斥问题
	* 编译、运行、测试用例

## 互斥与同步

### LabWeek14 - Peterson算法
* 实验内容: Peterson 算法
    * 把 Lecture08 示例 alg.8-1~8-3 拓展到多个读线程和多个写线程，应用 Peterson 算法原理设计实现共享内存互斥。

### LabWeek15 - 进程同步
* 实验内容: 进程同步。
	* 内容1: 编译运行课件 Lecture18 例程代码
		* Algorithms 18-1 ~ 18-9
	* 内容2: 在 LabWeek13 的基础上用**信号量**解决线程池分配的互斥问题
		* 编译、运行、测试用例
		* 提交新的设计报告

## 调度

### LabWeek16 - CPU调度
* 基本问题：讨论课件 Lecture19-20 中 CPU 调度算法的例子，尝试基于 POSIX API设计一个简单调度器（不考虑资源竞争问题）：
    * 创建一些 Pthread 线程任务，建立一个管理链队列，结点内容起码包括到达时间、WCT、优先级、调度状态（运行、就绪、阻塞）等调度参数；
    * 每个任务有一个调度信号量，任务启动后在其调度信号量上执行 wait；
    * 调度器按照调度策略对处于运行态的任务（如果有的话）的调度信号量执行 wait，并选取适当任务的调度信号量执行 signal；
    * 实现简单调度策略：FCFS、SJB、Priority。分别计算任务平均等待时间。
* 拓展问题1：设计若干资源信号量模拟资源竞争情况；增加时间片参数实现RR调度；验证优先级反转；建立多个链队列实现多级反馈调度。
* 拓展问题2：设计一个抢占式优先策略实时调度器，测试在一个给定的工作负载下优先级反转的情况。

## 储存管理

### LabWeek17 - 虚拟存储管理
* 实验内容：虚拟存储管理。
    * 编写一个 C 程序模拟实现课件 Lecture24 中的请求页面置换算法包括FIFO、LRU (stack and matrix implementation)、Second Chance，并设计输入用例验证结果。
### LabWeek18 - 硬盘调度
* 实验内容：硬盘调度。
	* 编写 C 程序模拟实现课件 Lecture25 中的硬盘柱面访问调度算法 包括 FCFS、SSTF、SCAN、C-SCAN、LOOK、C-LOOK，并设计输入用例验证结果。

---

## uCoreLab

### uCoreLab01 - 操作系统的生成

1. 理解通过 make 生成执行文件的过程
2. 使用 qemu 执行并调试 lab1 中的软件
3. 分析 bootloader 进入保护模式的过程
4. 分析 bootloader 加载 ELF 格式的 OS 的过程
5. 实现函数调用堆栈跟踪函数，并解释最后一行各个数值的含义
6. 完善中断初始化和处理

### uCoreLab02 - 内存管理

1. 实现 first-fit 连续物理内存分配算法
2. 实现寻找虚拟地址对应的页表项
3. 释放某虚地址所在的页并取消对应二级页表项的映射
### 