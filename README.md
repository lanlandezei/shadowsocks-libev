# shadowsocks-libev
shadowsocks-libev   snap一键安装脚本，使用的UFW防火墙

支持系统 debian9+ ubuntu16+ centos7.5+ fedora

参考资料：如何部署一台抗封锁的Shadowsocks-libev https://gfw.report/blog/ss_tutorial/zh/

服务端用到的是shadowsocks-libev https://github.com/shadowsocks/shadowsocks-libev/releases

从snap软件库安装 https://snapcraft.io/core

只支持这两种加密协议aes-256-gcm chacha20-ietf-poly1305，支持AES就用aes-256-gcm，不支持就用chacha20-ietf-poly1305

安装完请务必使用UFW防火墙添加客户端使用的IP。

### 安装方法
```
wget --no-check-certificate https://raw.githubusercontent.com/lanlandezei/shadowsocks-libev/main/install.sh && chmod +x install.sh && bash install.sh
```
```
请选择执行的操作
1.选择安装的加密协议：aes-256-gcm
2.选择安装的加密协议：chacha20-ietf-poly1305
3.检查SS运行状态
4.重启SS
5.防火墙添加放行IP和端口(重要)
—————————————————————————
配置文件路径：/var/snap/shadowsocks-libev/common/etc/shadowsocks-libev/config.json
修改配置文件请重启SS
选择执行的操作1-5：
```
### 防火墙添加放行IP和端口
```
打开ip138.com或者百度显示的IP填入
只能填入以下3种格式，<<示例>>
--------------------------
单个IP：114.114.114.114
IP段：114.114.114.0/24
更大范围：114.114.0.0/16
--------------------------
请输入添加放行防火墙的IP或IP段：
```
