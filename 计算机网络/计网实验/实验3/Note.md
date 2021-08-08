# 实验3操作流程

Keyword: 实验室、网络

## 实验基础设施

* 两台 RG-S5750 三层交换机
* 两台 RG-RSR20 路由器

* 每台PC使用3块网卡
    * 连接实验台网络设备
    * 搭建实验网络
    * 无线网卡，搭建无线实验网络

* IP信息(xx为机柜号)
    * 设备名 RCMS-xx
    * IP地址 172.16.xx.5/16
    * 学生IP 172.16.xx.1-4/16
    * 学生网关 172.16.0.1

## 一键清操作

一键清除试验台上网络设备的配置。

方法：

1. Win+R快捷键打开CMD
2. CMD输入 - telnet 172.16.xx.5
3. 浏览器打开网站 - https://172.16.xx.5:8080
4. 点击网站对应交换机/服务器LOGO
5. 进入特权模式 - 在弹出的窗口中输入:enable 14  
6. 输入登录密码 - b402
7. 在#模式下，输入： exec clear.txt （启动后设备会自动软重启，恢复配置）
   
1. 进入全局配置模式 - configue terminal
    * 普通用户模式 >
    * 特权模式 #
    * 全局配置模式 (config)#
        * 线路配置模式 (config-line)#
        * 接口配置模式 (config-if)#
2. 其他功能
    * 获取帮助 - ? 或者 show ?
    * 命令简写
    * 使用历史命令 - 向上键/向下键选择
3. 清楚串口堵塞
    * 登录RCMS
        - telnet 172.16.xx.5
        - en 14
    * 发指令
        - clear line tty 设备号码（1-2表示交换机、3-4表示路由器）
## 接口编号规则

（配置设备时需要）

* 交换机：插槽号/端口在插槽上的编号

    * 例如 端口所在的插槽编号为0，端口在插槽上的编号为3，则对应端口编号为0/3
    * gigabitethernet 千兆
    * fastethernet 百兆
    * 进入gigabitethernet 0/1示例：
        * Switch(config)# interface gigabitethernet 0/1

* 路由器：接口号由槽号/端口号
    * 端口号表示该接口在某个槽上的顺序号
    * 进入2/0接口示例：
        * Router(config)# interface serial 2/0

## 启用/禁止接口

* 接口的两种管理状态：up（端口开启）和down（端口被关闭）

* 关闭接口的例子
```
Switch(config)#interface gigabitethernet 0/2
Switch(config-if)#shutdown
```

* no形式重新启动一个接口
* ```
Switch(config-if)#no shutdown
```
--