#!/bin/bash

apt update && apt upgrade -y && apt autoremove -y
apt -y install wget curl nano lsb-release gnupg-agent apt-transport-https ca-certificates software-properties-common
printf "overlay\nbr_netfilter\n" >> /etc/modules-load.d/containerd.conf

printf "net.bridge.bridge-nf-call-iptables = 1\nnet.ipv4.ip_forward = 1\nnet.bridge.bridge-nf-call-ip6tables = 1\n" >> /etc/sysctl.d/99-kubernetes-cri.conf

wget https://github.com/containerd/containerd/releases/download/v1.6.16/containerd-1.6.16-linux-amd64.tar.gz -P /tmp/
tar Cxzvf /usr/local /tmp/containerd-1.6.16-linux-amd64.tar.gz
wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service -P /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now containerd

wget https://github.com/opencontainers/runc/releases/download/v1.1.4/runc.amd64 -P /tmp/
install -m 755 /tmp/runc.amd64 /usr/local/sbin/runc

wget https://github.com/containernetworking/plugins/releases/download/v1.2.0/cni-plugins-linux-amd64-v1.2.0.tgz -P /tmp/
mkdir -p /opt/cni/bin
tar Cxzvf /opt/cni/bin /tmp/cni-plugins-linux-amd64-v1.2.0.tgz

mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml
sed -i "s|SystemdCgroup = false|SystemdCgroup = true|g" /etc/containerd/config.toml

systemctl enable --now containerd
systemctl restart containerd

swapoff -a
sed -i '/swap.img/ s/^/#/g' /etc/fstab
echo "vm.swappiness=0" | tee --append /etc/sysctl.conf

curl -fsSLo - https://dl.k8s.io/apt/doc/apt-key.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/google-cloud-packages-archive-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
echo 'deb http://apt.kubernetes.io/ kubernetes-xenial main' | tee /etc/apt/sources.list.d/kubernetes.list

apt upgrade -y && apt autoremove -y

apt-get install -y kubelet=1.26.1-00 kubeadm=1.26.1-00 kubectl=1.26.1-00 && apt-mark hold kubelet kubeadm kubectl

read -e -p $'Do you want to \e[31mreboot now\033[0m ? : ' -i "y" if_reboot_at_end
if [[ $if_reboot_at_end =~ ^([Yy])$ ]]
then
	reboot
	exit
fi
