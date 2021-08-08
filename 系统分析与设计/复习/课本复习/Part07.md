# Part07 Designing Objects with Patterns

[toc]

## Chap26 应用GoF设计模式

1. **适配器（Adapter）**

   * 问题：如何解决不相容的接口问题，或者如何为具有不同接口的类似构件提供稳定接口。
   * **解决方案：通过中介适配器对象，将构件的原有接口转换为其他接口。**
   * 对于选定的外部服务，将使用一个特定的适配器实例来表示。类型名称常加上“Adapter”

   ![image-20210712213702832](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210712213702832.png)

2. **工厂（Factory）**简单工厂（不是GoF设计模式，是GoF抽象工厂模式的简化）

   * 问题：当有特殊考虑时，应该有谁负责创建对象？

   * **解决方案：创建称为工厂的纯虚构对象来处理这些创建职责。**

   * 优点：
     * 分离复杂创建的职责，并将其分配给内聚的帮助者对象
     * 隐藏潜在的复杂创建逻辑
     * 支持高性能的内存管理策略

   ![image-20210712220135948](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210712220135948.png)

3. **单实例类（Singleton）**

   * 问题：只有唯一实例的类称为单实例类，对象需要全局可见性和单点访问。

   * 解决方案：对类**定义一个返回单实例的静态方法**。（getInstance）

     ![image-20210712221547922](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210712221547922.png)

4. **策略（Strategy）**

   * 问题：如何设计变化但相关的算法和政策？如何设计才能使这些算法和政策有可变更的能力？

   * 解决方案：在单独的类中分别定义每种算法、策略、政策，并使其具有共同接口。

   * 需要注意的是，往往使用工厂创建策略

     ![image-20210712222254834](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210712222254834.png)

5. 组合（Composite）

   * 问题：如何能够像处理非组合对象一样，处理一组对象或具有组合结构的对象？

   * 解决方案：**定义*组合*和原子对象的类**，使它们实现相同的接口

     ![image-20210712222923476](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210712222923476.png)

     ![image-20210712222942846](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210712222942846.png)

6. **外观（Facade）**

   * 问题：对一组完全不同的实现或接口需要公共的统一的接口。可能会与子系统内部的大量事物产生耦合，或者子系统的实现可能会改变，怎么办？
   * 对子系统定义唯一的接触点 - 使用外观对象封装子系统。该外观对象是前端对象，是对子系统服务的唯一入口，而子系统的实现和其他构建是私有的。（外观通常是单例访问的，它将一个子系统隐藏在一个对象之后）

7. 观察者模型（Observer），也叫做订阅/委派事件模型

   * 问题：不同类型的订阅者对象关注于发布者的窗台变化或事件，并且想要在发布者发生是事件时以自己独特的方式做出反应。发布者想要保持与订阅者的低耦合，如何设计？

   * **解决方案：定义“订阅者”或“监听器”接口，订阅者实现此接口，发布者可以动态注册关注某个事件的订阅者，并在事件发生时通知它们。**

     ![image-20210712224352467](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210712224352467.png)

     ![image-20210712224611915](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210712224611915.png)

     ![image-20210712224709117](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210712224709117.png)



## Chap27-34

1. 活动图

   ![image-20210712225631885](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210712225631885.png)

2. 状态机（state machine diagram） 

   ![image-20210712225704207](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210712225704207.png)

3. 用力关联：
   1. 包含关系（include）
   2. 扩展关系（extend）
   3. 泛化关系（generalization）

## Chap35 包的设计

1. 组织包结构的准则

   1. 包在水平和垂直划分上的功能内聚

   2. 将一组功能上相关的接口放入单独的包，与其实现类分离

   3. 用于证实工作的包和用于聚集不稳定类的包

   4. 指责越多的包越需要稳定，通过以下方法增加稳定性

      1. 包中仅包含主要接口和抽象类
      2. 不依赖于其他包，或者只依赖非常稳定的包
      3. 包含的代码都相对稳定，已经过测试和细化
      4. 强制规定不允许频繁修改，具有缓慢的变化周期

   5. 将不相关的类型分离出去

   6. 使用工厂模式较少对具体包的依赖

   7. 包与包之间没有循环依赖，解决方案：

      1. 将参与循环的类型分解出来形成小的包

      2. 使用接口打破循环

         ![image-20210712232058554](C:\Users\17727\AppData\Roaming\Typora\typora-user-images\image-20210712232058554.png)

