# skynet
这里是[skynet舍区](https://www.skynetlua.com/)的源代码。使用[meiru(美茹)框架](https://github.com/skynetlua/meiru-skynet)开发。
[meiru(美茹)框架](https://github.com/skynetlua/meiru-skynet)是首个使用skynet框架开发的web framework，详情请见github上的[meiru(美茹)框架](https://github.com/skynetlua/meiru-skynet)介绍。
[skynet舍区](https://www.skynetlua.com/)的开发，借鉴了[nodeclub社区](https://github.com/cnodejs/nodeclub/)，前端也是移植自[nodeclub社区](https://github.com/cnodejs/nodeclub/)。

[meiru(美茹)框架](https://github.com/skynetlua/meiru-skynet)和[skynet舍区](https://www.skynetlua.com/)由[linyouhappy](https://github.com/linyouhappy)利用业余时间，历时5个月开发出来。设计的目的是用于开发游戏后台，以及建立skynet舍区。

# 有如下特性
1. 社区支持http和https两种方式访问。
2. 凭借lua的协程，整个项目不使用回调函数，代码简洁明了。
3. 数据库只使用mysql，meiru框架自身设计了众多缓冲机制，可以大幅降低数据库的开支。
4. meiru框架有model模块，把mysql的访问设计成mongodb。可以像mongodb一样使用mysql。
5. meiru框架的model模块，只需要定好mysql表文件，就可以快速使用。
5. 凭借skynet的多核处理能力，skynet舍区可以运行在十几个CPU核上，轻松应对每秒钟同时10万次访问。
6. meiru设计了丰富的错误处理机制，让你从容查找到错误所在。
7. meiru集成了http/https和ws/wss。例如，同一端口443，可以同时支持https请求和wss请求，无需对其设置不同的端口。

## 快速使用
推荐在centos7系统运行
目前适配的系统：centos7,ubuntu,macox。其他系统尚未适配过。

centos7安装git工具
```
sudo yum install -y git
```
ubuntu安装git工具
```
sudo apt-get install -y git
```

### 1. 下载源代码，或者使用git克隆
```
git clone https://github.com/skynetlua/skynetlua.git
```

### 2. 配置工程
```
cd yourfolder/skynetlua
./meiru/bin/meiru setup
```
meiru setup会自动下载安装gcc，autoconf，readline，openssl等。

### 3. 编译工程
```
./meiru/bin/meiru build
```
该命令会自动进行编译。编译后，生成skynet程序，就可以在其他主机运行，而无需要再次编译。
如果要清理编译文件，可执行
```
./meiru/bin/meiru clean
```

### 4. 配置数据库
安装MariaDB或者mysql。账号密码看源代码的配置文件:`./test/config/config.common`
meiru的mysqlcheckd模块，在启动配置文件auto_mysql = 1，就会启动，会自动从`./test/assets/config/test.sql`中导入数据库中。
数据库文件`./test/assets/config/test.sql`有任何表修改，mysqlcheckd模块就会drop旧表，创建最新的表格。
请在发布版本上，不要设置auto_mysql = 1，以免数据丢失。
mysqlcheckd模块功能简单，因时间急迫，未做太多的支持。

### 5. 启动工程
运行debug模式
```
./meiru/bin/meiru start test
```
浏览器打开127.0.0.1:8080。既可以看到结果


运行release模式
```
./meiru/bin/meiru start remote
```
浏览器打开127.0.0.1。既可以看到结果

### 6. 停止服务
```
./meiru/bin/meiru stop test
```

## https支持
项目源码已携带了一年期的https证书。此证书是skynetlua.com的。在本地电脑，需要修改hosts文件，把127.0.0.1指向www.skynetlua.com
这样浏览器访问www.skynetlua.com的时候，跳转到本地IP127.0.0.1。就可以以https的方式访问。
https证书放在`./test/assets/config/`文件夹.

## 项目结构介绍
项目有两个文件夹。meiru文件是meiru框架的目录。test文件夹就是社区的实现代码.
meiru目录请见[meiru(美茹)框架](https://github.com/skynetlua/meiru-skynet)
现在简单介绍test目录
```
test/
    assets/
          config  -- 配置文件
          static  -- web的静态资源
          view    -- 动态网页 即elua，类似ejs文件
    config/
    	  config.common -- 共享配置文件，把相同的配置放这里，其他配置文件可以导入它。
          config.remote -- release模式
          config.test   -- debug模式
    log
    lualib/
    		common    -- 公共库
            component -- 自定义组件
            config    -- 数据配置表
            controller -- 控制器
            model      -- model
            module     -- ws的控制器，类似controller
            preload    -- skynet服务的预加载文件
            proxy      -- 数据model的代理
            config.lua -- 社区网站的配置文件
            router.lua -- 路由文件，把url与controller的方法绑定
            vscode_debug.lua -- 方便vscode的lua插件调试使用。
            web.lua    -- http入口文件
            ws.lua    -- websocket入口文件
    service/
           main.lua  --启动文件
```

## 最后
社区源代码skynetlua使用过程中，遇到问题，请在github上反馈。谢谢您的支持！！！


