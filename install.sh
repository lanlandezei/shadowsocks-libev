#!/bin/bash
# Auto install shadowsocks/shadowsocks-libev Server
# System Required:   debian9+ ubuntu16+ centos7.5+ fedora
# (C) 2021-07 lanlandezei github.com/lanlandezei/shadowsocks-libev
#
# Reference URL:
# https://github.com/shadowsocks/shadowsocks-libev
# https://gfw.report/blog/ss_tutorial/zh/
port=`echo $[$RANDOM%90000+10000]`
version=`cat /etc/os-release | grep "^ID=" | cut -d= -f2 | tr -d '"'`
red(){
    echo -e "\033[31m\033[01m$1\033[0m"
}
green(){
    echo -e "\033[32m\033[01m$1\033[0m"
}

ufwin()
{
	while true
	do
	cat <<-END
	打开ip138.com或者百度显示的IP填入
	只能填入以下3种格式，<<示例>>
	--------------------------
	单个IP：114.114.114.114
	IP段：114.114.114.0/24
	更大范围：114.114.0.0/16
	--------------------------
	END
		read -p "请输入添加放行防火墙的IP或IP段：" ip1
		read -p "请输入放行端口：" port
		if [[ ! -z `echo $ip1 | sed -nr -e '/([0-9]{1,3}\.){3}[0]\/24/p' -e '/([0-9]{1,3}\.){2}[0]\.{1}[0]{1}\/16/p'` ]];then
			ufw allow from $ip1 to any port $port proto tcp
			ufw status
			break
		elif [[ ! -z `echo $ip1 | grep -o -E '([0-9]{1,3}\.){3}[0-9]{1,3}'` ]];then
			ufw allow from $ip1 to any port $port proto tcp
			ufw status
			break
		else
			echo ""
			red ">>请输入正确的IP或IP段<<"
			echo ""
			continue
		fi	
	done
}
ufwinstall()
{
case $version in
	centos)
	while true 
	do
		yum list installed | grep "^ufw" &>/dev/null
		if [ $? -ne 0 ];then
		green "ufw 未安装，即将安装"
			systemctl stop firewalld
			systemctl disable firewalld
			yum -y install epel-release
			yum -y install ufw
			systemctl start ufw
			systemctl enable ufw
			ufw allow 22
			echo y | ufw enable
		else
			break
		fi
	done
	ufwin
	;;
	debian)
	while true 
	do
		apt list --installed | grep "^ufw" &>/dev/null
		if [ $? -ne 0 ];then
		green "ufw 未安装，即将安装"
			apt -y install ufw
			systemctl start ufw
			systemctl enable ufw
			ufw allow 22
			echo y | ufw enable
		else
			break
		fi
	done
	ufwin
	;;
	ubuntu)
	ufw allow 22
	echo y | ufw enable
	ufwin
	;;
	fedora)
	while true 
	do
		dnf list installed | grep "^ufw" &>/dev/null
		if [ $? -ne 0 ];then
		green "ufw 未安装，即将安装"
			systemctl stop firewalld
			systemctl disable firewalld
			dnf -y install ufw
			systemctl start ufw
			systemctl enable ufw
			ufw allow 22
			echo y | ufw enable
		else
			break
		fi
	done
	ufwin
	;;
	*)
	read "不支持该系统"
	;;
esac
}

while true
do
	cat <<-END
	————————————————————————
	请选择执行的操作
	1.选择安装的加密协议：aes-256-gcm 
	2.选择安装的加密协议：chacha20-ietf-poly1305 
	3.检查SS运行状态
	4.重启SS
	5.防火墙添加放行IP和端口(重要)
	—————————————————————————
	配置文件路径：/var/snap/shadowsocks-libev/common/etc/shadowsocks-libev/config.json
	修改配置文件请重启SS
	END
	read -n1 -p "选择执行的操作1-5：" key
	if [[ $key -eq 1  ]];then
		key=aes-256-gcm
		echo ""
		echo  "选择的加密协议为：$key"
		break
	elif [[ $key -eq 2 ]];then
		key=chacha20-ietf-poly1305
		echo ""
		echo  "选择的加密协议为：$key"
		break
	elif [[ $key -eq 3 ]];then
		systemctl status snap.shadowsocks-libev.ss-server-daemon.service
		exit
	elif [[ $key -eq 4 ]];then
		systemctl restart snap.shadowsocks-libev.ss-server-daemon.service
		exit
	elif [[ $key -eq 5 ]];then
		ufwinstall
		exit
	else
		red "请输入正确数字1-5："
		continue
	fi
done

conf()
{
cat <<-END
{
    "server":["::0","0.0.0.0"],
    "server_port":$port,
    "method":"$key",
    "password":"$pass",
    "mode":"tcp_only",
    "fast_open":false
}
END
}
inst()
{
[ -d /var/snap/shadowsocks-libev/common/etc/shadowsocks-libev ] || mkdir -p /var/snap/shadowsocks-libev/common/etc/shadowsocks-libev
[ -f /var/snap/shadowsocks-libev/common/etc/shadowsocks-libev/config.json ] || touch /var/snap/shadowsocks-libev/common/etc/shadowsocks-libev/config.json
conf > /var/snap/shadowsocks-libev/common/etc/shadowsocks-libev/config.json
snap list | grep "^shadowsocks"
if [ $? -eq 0 ];then	
systemctl start snap.shadowsocks-libev.ss-server-daemon.service
systemctl enable snap.shadowsocks-libev.ss-server-daemon.service
systemctl restart snap.shadowsocks-libev.ss-server-daemon.service
ssstatus=$(systemctl is-active snap.shadowsocks-libev.ss-server-daemon.service)
	case $ssstatus in
	active)
	green "启动成功"
cat <<-END
端口: $port
密码：$pass
协议：$key
------------
配置文件路径：/var/snap/shadowsocks-libev/common/etc/shadowsocks-libev/config.json
------------
END
	;;
	*)
	red "shadowsocks-libev未启动，请重新执行脚本"
	;;
	esac
else
	red "shadowsocks-libev未安装完成，请重新执行脚本"
fi
}

while true
do
	case $version in
		debian)
		apt update
		apt -y install sudo net-tools openssl
		pass=`openssl rand -base64 16`
		apt -y install snapd
		snap install core
		snap install shadowsocks-libev --edge
		inst
		break
		;;
		ubuntu)
		apt update
		apt -y install sudo net-tools openssl
		pass=`openssl rand -base64 16`
		apt -y install snapd
		snap install core
		snap install shadowsocks-libev --edge
		inst
		break
		;;
		centos)
		yum -y install epel-release sudo net-tools
		pass=`openssl rand -base64 16`
		yum -y install snapd 
		systemctl enable --now snapd.socket
		ln -s /var/lib/snapd/snap /snap
		snap install core
		snap install shadowsocks-libev --edge
		inst
		break
		;;
		fedora)
		yum -y install sudo net-tools
		pass=`openssl rand -base64 16`
		dnf -y install snapd
		snap install core
		snap install shadowsocks-libev --edge
		[ -L /snap ] || ln -s /var/lib/snapd/snap /snap
		inst
		break
		;;
		*)
		read "不支持该系统"
		break
		;;
	esac
done
