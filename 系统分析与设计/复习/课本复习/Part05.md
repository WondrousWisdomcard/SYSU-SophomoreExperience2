# Part05 Object Modeling 对象建模

## PDF内容

> None

## Chap14 迈向对象设计

1. 设计对象的三种方式：编码、绘图再编码、只绘图不编码

2. 敏捷建模：使用大量白板、一同建模、并行创建若干模型

3. 对象设计：静态建模与动态建模

   1. 静态建模：有助于设计包、类名、属性和方法特征标记，如UML类图
   2. 动态建模：有助于设计逻辑、代码行为和方法体，例如UML交互图（顺序图和通信图）
   3. 敏捷建模是对两种模式的并行创建模型、动态花费较少时间，然后转到相应的静态建模，交替进行。

4. **CRC卡：**类职责协作卡是纸质的索引卡片，记录了类的职责（Responsibility）和协作（Collaborator）

   ![image-20210712081639574](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210712081639574.png)

## Chap15 UML交互图

1. **交互图（interaction diagram）：UML使用交互图来描述对象间通过消息的交互，用于动态建模**（dynamic object modeling），交互图有顺序图（sequence diagram）和通信图（communication diagram）。

2. 顺序图是以一种栅栏格式描述交互，其中在右侧添加新创建的对象。

   ![image-20210712082745729](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210712082745729.png)

3. 通讯图：以图或网格描述对象交互，其中对象可位于图中任何位置

   ![image-20210712082855676](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210712082855676.png)

4. 顺序图和通讯图的优缺点：

   1. 顺序图有更强的表示能力，UML工具对其支持也更好
   2. 采用顺序图可以更方便地表示调用流的顺序，而对于通信图必须查阅顺序编号
   3. 顺序图更容易文档化
   4. 在墙上绘制UML草图时使用通信图更合适，能有效利用空间，并且易于修改。而绘制顺序图空间利用的不是很好
   5. 通信图能在更小的视觉空间容纳更多的内容

5. UML顺序图表示法：

   ![image-20210712085455548](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210712085455548.png)

   * 生命线框

     ![image-20210712085757814](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210712085757814.png)

   * 单实例对象(Singleton)

     ![image-20210712085913390](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210712085913390.png)

   * 消息：实心箭头+消息表达式

     ![image-20210712090057983](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210712090057983.png)

   * 返回应答和发送给自身的消息

     ![image-20210712090200582](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210712090200582.png)

   * 对象的创建和销毁：创建使用虚线箭头

     ![image-20210712090307748](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210712090307748.png)

   * 图框：操作符/标签/条件子句

     ![image-20210712090500699](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210712090500699.png)

     ![image-20210712090601176](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210712090601176.png)

   * 关联交互图：引用+放置图框

     ![image-20210712090703205](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210712090703205.png)

   * 多态案例：使用多个顺序图

     ![image-20210712090916951](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210712090916951.png)

   * 异步调用与主动对象

     ![image-20210712091114670](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210712091114670.png)

6. UML通信图表示法：

   ![image-20210712085545967](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210712085545967.png)

   * 消息以及消息的编号

     ![image-20210712091356258](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210712091356258.png)![image-20210712091420151](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210712091420151.png)![image-20210712091632510](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210712091632510.png)

   * 实例的创建：

     ![image-20210712091515253](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210712091515253.png)

   * 条件、循环：

     ![image-20210712091728271](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210712091728271.png)

     ![image-20210712091750952](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210712091750952.png)

   * 多态：

     ![image-20210712091846557](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210712091846557.png)

   * 主动对象与异步调用：

     ![image-20210712091924141](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210712091924141.png)

   

## Chap16 UML类图

0. 设计类图（DCD Design class diagram）

1. **UNL类图（class diagram）表示类、接口和关联，类图用于静态对象建模**

   ![image-20210712105818425](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210712105818425.png)

2. 类元（classifier）：描述行为和结构特性的模型元素，类、接口、用例和参与者都是类元的特化。

   类元表示法包括：属性文本表示法、关联线表示法、综合二者。

   * 属性文本表示法：

     visivility name : type multiplicity = default {property-string}

   * 关联线表示法（设计模型）：
     * 导航性箭头：源对象指向目标对象（多重性放在目标的那一边）
     * 角色名：只放在目标端，表示属性名称
     * 不需要关联名称

   ![image-20210712110604137](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210712110604137.png)

   * 对数据类型使用属性文本表示法，对其他对象使用关联线。

     ![image-20210712110851167](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210712110851167.png)

3. UML注解符号：注解、注释、约束、方法体

   1. 注解、注释：定义不能有语义冲突
   2. 约束：必须使用大括号将其括起来
   3. 方法体：UML操作的实现

4. **UML操作的格式：**

   **visibility name {parameter-list} : return-type {property-string}**

5. UML方法（method）：操作的实现。在交互图中，通过消息的细节和顺序来表示，在类图中，使用构造型《mehtod》的UML注解符号。

   ![image-20210712111804462](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210712111804462.png)

6. UML关键字：

   ![image-20210712112320514](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210712112320514.png)

7. UML构造型（stereotype）：表示对先用概念模型的精化，也使用“《》”标识构造型

   UML简档（profile）：一组相关构造型、标记和约束的集合。

   ![image-20210712112813615](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210712112813615.png)

8. UML特性（property）：表示元素特征的已命名的值，特性字符串采用：{name1 = value1, name2 = value2}的形式，name可以是abstract、visibility等。

9. UML泛化（generalization）：用由子类到超类的实线和空心三角箭头表示。

   抽象类（abstract class）采用{abstract}标记；种植类（final class）采用{leaf}进行标记。

10. 依赖（dependency）：用从客户到提供者的虚线箭头表示，常见的依赖类型包括：

    1. 拥有提供者类型的属性
    2. 向提供者发送消息
    3. 接收提供者的参数
    4. 提供者是超类或接口

    在类图中，使用依赖线来描述对象之间的全局变脸、参数变脸、局部变量和静态方法的依赖

    ![image-20210712122746517](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210712122746517.png)

    依赖标签：

    ![image-20210712122943432](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210712122943432.png)

11. 接口（interface）：插座表示法、依赖线表示法、棒棒糖表示法

    ![image-20210712123053845](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210712123053845.png)

12. 约束（constraint）：对元素的限制或条件，用大括号加文本来表示

    ![image-20210712124210507](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210712124210507.png)

13. 限定关联（qualified association）：具有限定符（qualifier），限定符用于从规模较大的相关对象集合中，依据限定符的键选择一个或多个对象。

    ![image-20210712124441355](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210712124441355.png)

14. 关联类：允许将关联本身作为类

    ![image-20210712124551687](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210712124551687.png)

15. 单实例类：在右上角标个1就好了

16. 模板（template）类：图中K表示模板参数

    ![image-20210712124751946](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210712124751946.png)

17. 主动（active）类：主动对象运行于自己控制的线程之上，用双竖线类框来表示。

    ![image-20210712125228313](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210712125228313.png)

