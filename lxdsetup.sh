#!/bin/bash

MACHINES=`seq 2 10`

echo Initializing images
for i in $MACHINES;do sudo lxc launch images:centos/7/amd64 centos$i;done

echo Sleeping for a bit to avoid yum timeout
for wait in `seq 1 10`;
do
	echo $wait
	sleep 1
	sudo lxc exec centos0 -- ip addr|fgrep inet|fgrep eth0
done

echo Setting up bootstrap node
#sudo lxc exec centos0 -- bash -c "cd /tmp && curl -O https://downloads.dcos.io/dcos/stable/dcos_generate_config.sh"
#sudo lxc exec centos0 -- bash -c "yum -y install squid"
#sudo lxc exec centos0 -- systemctl enable squid
#sudo lxc exec centos0 -- systemctl start squid
IPCENTOS0=`sudo lxc info centos0|fgrep inet|fgrep eth0|fgrep -v inet6|tr -d ' '|tr '\t' ' '|cut -d ' ' -f3`



echo Installing rpms
for i in $MACHINES;
do 
	sudo lxc exec centos$i -- bash -c "http_proxy=http://$IPCENTOS0:3128 yum -y install openssh-server sudo openjdk-devel"
done

echo Installing sshd service
for i in $MACHINES;do sudo lxc exec centos$i -- systemctl start sshd.service; done

echo Adding lxd user
for i in $MACHINES;
do 
	sudo lxc exec centos$i -- adduser lxd
	sudo lxc exec centos$i -- bash -c "echo lxd | passwd --stdin lxd"
	sudo lxc exec centos$i -- usermod -aG wheel lxd
done


sleep 3
sudo lxc list
