# Lab Week18 - 硬盘调度

**郑有为 19335286**

如果图片或链接显示异常，请访问 [OSHomework-LabWeek18.md(Gitee)](https:gitee.com/WondrousWisdomcard/oshomework/blob/master/LabWeek18/LabWeek18.md)。我把代码和截图都放在了仓库 [OSHomework(Gitee)](https:gitee.com/WondrousWisdomcard/oshomework)。

## 目录

* 实验内容：硬盘调度。
  * 编写 C 程序模拟实现课件 Lecture25 中的硬盘柱面访问调度算法 包括 FCFS、SSTF、SCAN、C-SCAN、LOOK、C-LOOK，并设计输入用例验证结果。

[toc]

## 实验原理

* FCFS：先到先服务。
* SSTF: 最短寻道时间优先，每次选择处理距离当前磁头位置的最短寻道时间请求，并非最优算法，但效果比较好。
* SCAN: 电梯调度算法，根据磁头当前的移动方向，先依次处理当前方向的请求，碰到磁盘边缘后在反方向处理另一端请求。
* C-SCAN: 循环扫描算法，根据磁头当前的移动方向，先依次处理当前方向的请求，碰到磁盘边缘后在移动到另一端边缘，保持原方向以此处理剩下的请求。
* LOOK: SCAN算法的改进，磁头只需要移动到最远的请求便开始反向处理请求，不必像SCAN需要移动到边缘。
* C-LOOK: C-SCAN算法的改进，磁头只需要移动到最远的请求便移动到另一端最远的请求同向处理，也不必像C-SCAN需要移动到边缘。

## 程序说明

六种模拟算法分别实现于六个函数（FCFS、SSTF、SCAN、C-SCAN、LOOK、C-LOOK）：函数参数包含请求串、串长度、初始磁头方向（选1-由外向里， 0-由里向外）。

```
int fcfs(int* request, int len);
int sstf(int* request, int len);

int scan(int* request, int len, int dir);
int c_scan(int* request, int len, int dir);

int look(int* request, int len, int dir);
int c_look(int* request, int len, int dir);
```

包含随机测试功能，只需在运行时加入运行时参数`random`即可进入随机测试，随机测试内容是进行给定次长度为10的调度测试，并计算每种算法的平均结果，相应代码在`void random_test(int times)`中实现。

## 程序测试

### 测试-1 随机测试

运行时参数加入random即可进行随机测试，如`./a.out random`，以下是随机测试结果：

100次随机测试平均值：
```
+--------------------------+
|Average res of random test|
+--------+--------+--------+
|  FCFS  |  SSTF  |  SCAN  |
|   576  |   219  |   293  |
+--------+--------+--------+
| C-SCAN |  LOOK  | C-LOOK |
|   381  |   257  |   308  |
+--------+--------+--------+
100 Random Test, Each test has 10 random request and random direction
```

1000次随机测试平均值：
```
+--------------------------+
|Average res of random test|
+--------+--------+--------+
|  FCFS  |  SSTF  |  SCAN  |
|   604  |   217  |   280  |
+--------+--------+--------+
| C-SCAN |  LOOK  | C-LOOK |
|   379  |   245  |   310  |
+--------+--------+--------+
1000 Random Test, Each test has 10 random request and random direction
```

**可以看到效果最好的是SSTF，其次是LOOK，SCAN，FCFS效果最差。**

### 测试-2

以下是教材中的测试样例：
柱面访问调度有8次，初始磁头位置是53,磁头的转动方向是自里向外，最外一层为0号柱面，八次访问调度以此是：98 183 37 122 14 124 65 67，以下是测试结果，与答案相符：

```
Enter the length of cylinder request: 8
Enter the initial position of disk head: 53
Enter the direction of disk head(out: 0 or in: 1): 0
Enter the cylinder request string(from 0 to 199): 98 183 37 122 14 124 65 67
[  FCFS  ]  53  98 183  37 122  14 124  65  67 
[  SSTF  ]  53  65  67  37  14  98 122 124 183 
[  SCAN  ]  53  37  14   0  65  67  98 122 124 183 
[ C-SCAN ]  53  37  14   0 199 183 124 122  98  67  65 
[  LOOK  ]  53  37  14  65  67  98 122 124 183 
[ C-LOOK ]  53  37  14 183 124 122  98  67  65 
+--------------------------+
|Total cyclinder-num moved |
+--------+--------+--------+
|  FCFS  |  SSTF  |  SCAN  |
|   640  |   236  |   236  |
+--------+--------+--------+
| C-SCAN |  LOOK  | C-LOOK |
|   386  |   208  |   326  |
+--------+--------+--------+
```

程序输出了每种调度算法下各个请求的执行次序，并输出了每种调度算法下，总的磁头移动柱面总数。：分别是 FCFS(640)、SSTF(236)、SCAN(236)、C-SCAN(386)、LOOK(208)、C-LOOK(326)，在本样例下，FCFS效率最低。

### 测试-3

测试初始磁头为0的情况下，磁头方向向内和向外两种情况的算法效果：


```
Enter the length of cylinder request: 4
Enter the initial position of disk head: 0
Enter the direction of disk head(out: 0 or in: 1): 0
Enter the cylinder request string(from 0 to 199): 15 1 6 20
[  FCFS  ]   0  15   1   6  20 
[  SSTF  ]   0   1   6  15  20 
[  SCAN  ]   0   1   6  15  20 
[ C-SCAN ]   0 199  20  15   6   1 
[  LOOK  ]   0   1   6  15  20 
[ C-LOOK ]   0  20  15   6   1 
+--------------------------+
|Total cyclinder-num moved |
+--------+--------+--------+
|  FCFS  |  SSTF  |  SCAN  |
|    48  |    20  |    20  |
+--------+--------+--------+
| C-SCAN |  LOOK  | C-LOOK |
|   397  |    20  |    39  |
+--------+--------+--------+
```

```
Enter the length of cylinder request: 4
Enter the initial position of disk head: 0
Enter the direction of disk head(out: 0 or in: 1): 1
Enter the cylinder request string(from 0 to 199): 15 1 6 20
[  FCFS  ]   0  15   1   6  20 
[  SSTF  ]   0   1   6  15  20 
[  SCAN  ]   0   1   6  15  20 199 
[ C-SCAN ]   0   1   6  15  20 199 
[  LOOK  ]   0   1   6  15  20 
[ C-LOOK ]   0   1   6  15  20 
+--------------------------+
|Total cyclinder-num moved |
+--------+--------+--------+
|  FCFS  |  SSTF  |  SCAN  |
|    48  |    20  |   398  |
+--------+--------+--------+
| C-SCAN |  LOOK  | C-LOOK |
|   398  |    40  |    40  |
+--------+--------+--------+
```

我们还可以看到，在请求比较集中时，由于SCAN和C-SCAN可能要进行整个磁道范围的移动，效果回比FCFS还要差。

## 总结

本次实验对六种磁盘调度算法（FCFS、SSTF、SCAN、C-SCAN、LOOK、C-LOOK）进行模拟，对程序进行测试并比较不同算法的效率。

