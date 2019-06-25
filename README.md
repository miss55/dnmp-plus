DNMP（Docker + Nginx + MySQL + PHP7/5 + Redis）是一款全功能的**LNMP 一键安装程序**。

**[[ENGLISH]](README-en.md)**

DNMP 项目特点：
1. `100%`开源
2. `100%`遵循 Docker 标准
3. 支持**多版本 PHP**共存，可任意切换（~~PHP5.4、~~PHP5.6、PHP7.2)
4. 支持绑定**任意多个域名**
5. 支持**HTTPS 和 HTTP/2**
6. **PHP 源代码、MySQL 数据、配置文件、日志文件**都可在 Host 中直接修改查看
7. 内置**完整 PHP 扩展安装**命令
8. 默认支持`pdo_mysql`、`redis`、`xdebug`、`swoole`等常用热门扩展，根据环境灵活配置
9. 带有 phpmyadmin 和 phpredisadmin 数据库在线管理程序
10. 实际项目中应用，确保`100%`可用
11. 一次配置，**Windows、Linux、MacOs**皆可用

# 目录
- [1.目录结构](#1目录结构)
- [2.快速使用](#2快速使用)
- [3.PHP 和扩展](#3PHP和扩展)
    - [3.1 切换 Nginx 使用的 PHP 版本](#31-切换Nginx使用的PHP版本)
    - [3.2 安装 PHP 扩展](#32-安装PHP扩展)
    - [3.3 Host 中使用 php 命令行（php-cli）](#33-host中使用php命令行php-cli)
- [4.添加快捷命令](#4添加快捷命令)
- [5.使用 Log](#5使用log)
    - [5.1 Nginx 日志](#51-nginx日志)
    - [5.2 PHP-FPM 日志](#52-php-fpm日志)
    - [5.3 MySQL 日志](#53-mysql日志)
- [6.使用 composer](#6使用composer)
- [7.数据库管理](#7数据库管理)
    - [7.1 phpMyAdmin](#71-phpmyadmin)
    - [7.2 phpRedisAdmin](#72-phpredisadmin)
- [8.在正式环境中安全使用](#8在正式环境中安全使用)
- [9.常见问题](#9常见问题)
    - [9.1 如何在 PHP 代码中使用 curl？](#91-如何在php代码中使用curl)
    - [9.2 Docker 使用 cron 定时任务](#92-Docker使用cron定时任务)


## 1.目录结构

```plain
/
├── conf                        配置文件目录
│   ├── conf.d                  Nginx用户站点配置目录
│   ├── nginx.conf              Nginx默认配置文件
│   ├── mysql.cnf               MySQL用户配置文件
│   ├── php-fpm.conf            PHP-FPM配置文件（部分会覆盖php.ini配置）
│   └── php.ini                 PHP默认配置文件
├── Dockerfile                  PHP镜像构建文件
├── extensions                  PHP扩展源码包
├── log                         日志目录
├── mysql                       MySQL数据目录
├── docker-compose-sample.yml   Docker 服务配置示例文件
├── env.smaple                  环境配置示例文件
└── www                         PHP代码目录
```
结构示意图：

![Demo Image](./dnmp.png)


## 2.快速使用
1. 本地安装`git`、`docker`和`docker-compose`。
2. `clone`项目：
    ```plain
    $ git clone https://github.com/yeszao/dnmp.git
    ```
3. 如果不是`root`用户，还需将当前用户加入`docker`用户组：
    ```plain
    $ sudo gpasswd -a ${USER} docker
    ```
4. 拷贝并命名配置文件（Windows 系统请用 copy 命令），启动：
    ```plain
    $ cd dnmp
    $ cp env.sample .env
    $ cp docker-compose-sample.yml docker-compose.yml
    $ docker-compose up
    ```
    注意：Windows 安装 360 安全卫士的同学，请先将其退出，不然安装过程中可能 Docker 创建账号过程可能被拦截，导致启动时文件共享失败；
5. 访问在浏览器中访问：

 - [http://localhost](http://localhost)： 默认*http*站点
 - [https://localhost](https://localhost)：自定义证书*https*站点，访问时浏览器会有安全提示，忽略提示访问即可

两个站点使用同一 PHP 代码：`./www/localhost/index.php`。

要修改端口、日志文件位置等，请修改**.env**文件，然后重新构建：
```bash
$ docker-compose build php72    # 重建单个服务
$ docker-compose build          # 重建全部服务

```


## 3.PHP 和扩展
### 3.1 切换 Nginx 使用的 PHP 版本
默认情况下，我们同时创建 **PHP5.6 和 PHP7.2** 2 个 PHP 版本的容器，

切换 PHP 仅需修改相应站点 Nginx 配置的`fastcgi_pass`选项，

例如，示例的 [http://localhost](http://localhost) 用的是 PHP7.2，Nginx 配置：
```plain
    fastcgi_pass   php72:9000;
```
要改用 PHP5.6，修改为：
```plain
    fastcgi_pass   php56:9000;
```
再 **重启 Nginx** 生效。
```bash
$ docker exec -it dnmp_nginx_1 nginx -s reload
```
### 3.2 安装 PHP 扩展
PHP 的很多功能都是通过扩展实现，而安装扩展是一个略费时间的过程，
所以，除 PHP 内置扩展外，在`env.sample`文件中我们仅默认安装少量扩展，
如果要安装更多扩展，请打开你的`.env`文件修改如下的 PHP 配置，
增加需要的 PHP 扩展：
```bash
PHP72_EXTENSIONS=pdo_mysql,opcache,redis       # PHP 7.2要安装的扩展列表，英文逗号隔开
PHP56_EXTENSIONS=opcache,redis                 # PHP 5.6要安装的扩展列表，英文逗号隔开
```
然后重新 build PHP 镜像。
    ```bashplainplainplainplainplainplainplainplainplainplainplainplainplain
    docker-compose build php72
    docker-compose up -d
    ```
可用的扩展请看同文件的`PHP extensions`注释块说明。

### 3.3 Host 中使用 php 命令行（php-cli）
1. 打开主机的 `~/.bashrc` 或者 `~/.zshrc` 文件，加上：
```bash
php () {
    tty=
    tty -s && tty=--tty
    docker run \
        $tty \
        --interactive \
        --rm \
        --volume $PWD:/var/www/html:rw \
        --workdir /var/www/html \
        dnmp_php72 php "$@"
}
```
2. 让文件起效：
```plain
source ~/.bashrc
```
3. 然后就可以在主机中执行 php 命令了：
```bash
~ php -v
PHP 7.2.13 (cli) (built: Dec 21 2018 02:22:47) ( NTS )
Copyright (c) 1997-2018 The PHP Group
Zend Engine v3.2.0, Copyright (c) 1998-2018 Zend Technologies
    with Zend OPcache v7.2.13, Copyright (c) 1999-2018, by Zend Technologies
    with Xdebug v2.6.1, Copyright (c) 2002-2018, by Derick Rethans
```

## 4.添加快捷命令
在开发的时候，我们可能经常使用`docker exec -it`切换到容器中，把常用的做成命令别名是个省事的方法。

打开~/.bashrc，加上：
```bash
alias dnginx='docker exec -it dnmp_nginx_1 /bin/sh'
alias dphp72='docker exec -it dnmp_php72_1 /bin/sh'
alias dphp56='docker exec -it dnmp_php56_1 /bin/sh'
alias dmysql='docker exec -it dnmp_mysql_1 /bin/bash'
alias dredis='docker exec -it dnmp_redis_1 /bin/sh'
```

## 5.使用 Log

Log 文件生成的位置依赖于 conf 下各 log 配置的值。

### 5.1 Nginx 日志
Nginx 日志是我们用得最多的日志，所以我们单独放在根目录`log`下。

`log`会目录映射 Nginx 容器的`/var/log/nginx`目录，所以在 Nginx 配置文件中，需要输出 log 的位置，我们需要配置到`/var/log/nginx`目录，如：
```plain
error_log  /var/log/nginx/nginx.localhost.error.log  warn;
```


### 5.2 PHP-FPM 日志
大部分情况下，PHP-FPM 的日志都会输出到 Nginx 的日志中，所以不需要额外配置。

另外，建议直接在 PHP 中打开错误日志：
```php
error_reporting(E_ALL);
ini_set('error_reporting', 'on');
ini_set('display_errors', 'on');
```

如果确实需要，可按一下步骤开启（在容器中）。

1. 进入容器，创建日志文件并修改权限：
    ```bash
    $ docker exec -it dnmp_php_1 /bin/bash
    $ mkdir /var/log/php
    $ cd /var/log/php
    $ touch php-fpm.error.log
    $ chmod a+w php-fpm.error.log
    ```
2. 主机上打开并修改 PHP-FPM 的配置文件`conf/php-fpm.conf`，找到如下一行，删除注释，并改值为：
    ```plain
    php_admin_value[error_log] = /var/log/php/php-fpm.error.log
    ```
3. 重启 PHP-FPM 容器。

### 5.3 MySQL 日志
因为 MySQL 容器中的 MySQL 使用的是`mysql`用户启动，它无法自行在`/var/log`下的增加日志文件。所以，我们把 MySQL 的日志放在与 data 一样的目录，即项目的`mysql`目录下，对应容器中的`/var/lib/mysql/`目录。
```bash
slow-query-log-file     = /var/lib/mysql/mysql.slow.log
log-error               = /var/lib/mysql/mysql.error.log
```
以上是 mysql.conf 中的日志文件的配置。

## 6.使用 composer
**我们建议在主机 HOST 中使用 composer，避免 PHP 容器变得庞大**。
1. 在主机创建一个目录，用以保存 composer 的配置和缓存文件：
    ```plainplainplainplainplainplainplain
    mkdir ~/dnmp/composer
    ```
2. 打开主机的 `~/.bashrc` 或者 `~/.zshrc` 文件，加上：
    ```plain
    composer () {
        tty=
        tty -s && tty=--tty
        docker run \
            $tty \
            --interactive \
            --rm \
            --user $(id -u):$(id -g) \
            --volume ~/dnmp/composer:/tmp \
            --volume /etc/passwd:/etc/passwd:ro \
            --volume /etc/group:/etc/group:ro \
            --volume $(pwd):/app \
            composer "$@"
    }

    ```
3. 让文件起效：
    ```plain
    source ~/.bashrc
    ```
4. 在主机的任何目录下就能用 composer 了：
    ```plain
    cd ~/dnmp/www/
    composer create-project yeszao/fastphp project --no-dev
    ```
5. （可选）如果提示需要依赖，用`--ignore-platform-reqs --no-scripts`关闭依赖检测。
6. （可选）第一次使用 composer 会在 ~/dnmp/composer 目录下生成一个 config.json 文件，可以在这个文件中指定国内仓库，例如：
    ```plain
    {
        "config": {},
        "repositories": {
            "packagist": {
                "type": "composer",
                "url": "https://packagist.laravel-china.org"
            }
        }
    }

    ```

## 7.数据库管理
本项目默认在`docker-compose.yml`中开启了用于 MySQL 在线管理的*phpMyAdmin*，以及用于 redis 在线管理的*phpRedisAdmin*，可以根据需要修改或删除。

### 7.1 phpMyAdmin
phpMyAdmin 容器映射到主机的端口地址是：`8080`，所以主机上访问 phpMyAdmin 的地址是：
```plain
http://localhost:8080
```

MySQL 连接信息：
- host：(本项目的 MySQL 容器网络)
- port：`3306`
- username：（手动在 phpmyadmin 界面输入）
- password：（手动在 phpmyadmin 界面输入）

### 7.2 phpRedisAdmin
phpRedisAdmin 容器映射到主机的端口地址是：`8081`，所以主机上访问 phpMyAdmin 的地址是：
```plain
http://localhost:8081
```

Redis 连接信息如下：
- host: (本项目的 Redis 容器网络)
- port: `6379`


## 8.在正式环境中安全使用
要在正式环境中使用，请：
1. 在 php.ini 中关闭 XDebug 调试
2. 增强 MySQL 数据库访问的安全策略
3. 增强 redis 访问的安全策略


## 9.常见问题
### 9.1 如何在 PHP 代码中使用 curl
参考这个 issue：[https://github.com/yeszao/dnmp/issues/91](https://github.com/yeszao/dnmp/issues/91)

### 9.2 Docker 使用 cron 定时任务
[Docker 使用 cron 定时任务](https://www.awaimai.com/2615.html)

## License
MIT

