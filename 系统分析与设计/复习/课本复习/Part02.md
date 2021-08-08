# Part02 System Requirements Analysis 初始阶段

[toc]

## PDF内容

1. 初始阶段的主要任务：

   ![image-20210711081727038](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210711081727038.png)

2. 寻找需求的方法：

    ![image-20210711081929366](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210711081929366.png)

## Chap04 初始不是需求阶段

1. **初始阶段**（inception phase）：**建立项目共同设想和基本范围的比较简短的起始阶段**，但该阶段的任务不是定义所有需求，大多数需求分析都是在细化阶段进行的。

   初始阶段预见项目的范围、设想和业务案例，主要解决涉众是否就项目设想达成一致，项目是否值得继续认真研究。

2. 制品列表：形成一系列的初始、概略的文档，这些文档将在细化阶段不断精化

   ![image-20210710210759245](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210710210759245.png)

## Chap05 进化式需求

3. 需求：系统（项目）必须提供的能力和必须遵循的条件。
4. 需求的类型和种类：**FURPS+模型**
   1. **Functional 功能性**
   2. **Usability 可用性**
   3. **Reliability 可靠性**
   4. **Performance 性能**
   5. **Supportability 可支持性**
   6. \+ 实现、接口、操作、包装（Packaging）、授权（Legal）
5. 组织需求的制品：用例模型、补充性规格说明、词汇表、设想、业务规则

## Chap06 用例

6. **用例（use case）**：**一组相关的成功和失败场景的集合，用来描述参与者如何使用系统来实现其目标。**

   **用例是文本文档**，用例建模主要是编写文本的活动。

7. 参与者的分类以及为何确定：
   * 主要参与者（发现驱动用例的拥护目标）
   * 协助参与者（为了明确外部接口和协议）
   * 幕后参与者（为了确保确定并满足所有必要的重要事物）
8. 用例的表示法：**摘要、非正式、详述**

9. **详述用例（fully dressed use case）**：详细编写所有步骤以及各种变化，同时具有补充部分，如前置条件和后置保证，需要编写所有用例中10%具有重要架构意义和高价值的用例。

10. 用例的不同部分：

    ![image-20210710233003875](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210710233003875.png)

11. 用例举例以及各部分解释

    1. 级别：**用户目标级别和子功能级别**
    2. 扩展：描述了各种分支场景，包括这些场景的条件和处理方式
    3. **注意序号标识，与主场景是有一一对应的**

    ![image-20210710234128922](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210710234128922.png)

    ![image-20210710234159454](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210710234159454.png)

    ![image-20210710234216478](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210710234216478.png)

    ![image-20210710234409571](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210710234409571.png)

    ![image-20210710234721758](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210710234721758.png)

    ![image-20210710234932849](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210710234932849.png)

    ![image-20210710235002574](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210710235002574.png)

12. 编写用例的其他准则：

    1. 以无用户界面约束的本质风格编写用例

    2. 编写简洁的用例

    3. 编写黑盒用例

       ![image-20210710235520859](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210710235520859.png)

    4. 采用参与者和参与者目标的视点
    5. 判断用力是否有效：老板测试、EBP测试、规模测试

13. UML**用例图**表示法：

    ![image-20210711000546763](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210711000546763.png)

## Chap07 其他需求

14. **补充性规格说明（Supplementary specification）：捕获了用例或者词汇表难以描述的其他需求、信息和需求**

    包括“**FUPRS+**”（功能性、可用性、可靠性、性能、可支持性）需求、报表、硬件和软件约束、开发约束、国际化问题、文档化和帮助、许可和其他法律问题、包装、标准（技术、质量、安全）、物理环境问题、操作问题、特定的应用领域规则、领域信息。

15. **设想（Vision）**：

    内容包括：**简介、定位、涉众描述、产品概览、系统特性概要、其他需求和约束**

16. **词汇表（Glossary）**：重要术语及其定义的列表，也作为数据字典

    一个表项可以包含：**名称、定义和信息、格式、验证规则和别名**

17. **领域规则（Domain Rules）：**指出领域或业务是如何运作的，也被称为业务规则。公司政策、物理法则、政府法律都是常见的领域规则。

