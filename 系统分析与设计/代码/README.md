# 代码修改日志

|日期|修改内容|备注|姓名|
|-|-|-|-|
|2021.05.17|Mesh类初始代码|粗略甚至会被完全推翻的代码，主要是交流用|陈俊熹|
|2021.05.19|load、store函数|粗略编写了存取函数|林迪煊|

## 2021.05.17

今天上传了初始代码，是基于读取和存储都采用vtk格式的前提下写的。

考虑到vtk格式下的网格信息只有点和cell，Mesh类所存储的成员只有点和cell，其他一些元素如边、面等我还不好确定，还需要讨论是将这些元素的判定的生成，特别是cell、边和面，交由Mesh Application的编程者完成，还是内嵌到Mesh类中完成。

暂时考虑交由Mesh Application的编程者完成是考虑到类库运行时元素的删减会对整个Mesh结构产生影响，例如删去一个点，就很有可能导致Mesh中边、面和cell的属性产生影响。首先如果每次增删都要进行元素属性的更新，计算的时间长度没保证，可能会很长，如果短时间内进行多个删除和增加，时间与数量一乘可能会是很大的数，个人感觉交由Mesh Application的编程者决定可能会是一个方案。其次就是至少我个人对网格元素的判定的算法实在是了解不多，能不能做出来都是个问题。

综上就有了我修改的代码。



## 2021.05.19

1. 对Mesh.h 文件中定义的 Mesh 类做了一些修改，修改部分为：

```c
public:
		int nnode,ncell;
		static std::map<int,int> cellnode; /*key:celltype   value:nodenumber*/
```

- 增加了表示node数和cell数的 nnode和ncell

- 考虑到不同的celltype可能会有不同的顶点数，所以加入一个字典对每种 celltype做对应

此外存取函数的参数也有修改：

```c
Mesh* load_mesh_vtk(const char* pathname);
void store_mesh_vtk(const char* pathname,Mesh* mesh);
```





2. 初步编写了 load 和 store 的函数，目前我对存储结构的初步构想如下：

```
nnode  ncell  dimension 
X_1 Y_1 Z_1 				/*nnode个顶点的坐标*/
X_2 Y_2 Z_2
.
.
.
X_n Y_n Z_n

celltype_1			/*根据celltype，node的个数不相同*/
node_1_1 node_1_2 ...
celltype_2
node_2_1 node_2_2 ...
.
.
.
celltype_N
node_N_1 node_N_2 ...
```

大致与vtk的结构类似，store函数我只写了ASCII版本的，大家可以看看再改进一下。