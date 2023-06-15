# Setup Kubernetes 1.26 cluster on ubuntu-22.04 with containerd

> Kubernetes 1.26

> Containerd 1.6.16

> Calico 3.25 CNI

>Ubuntu 22.04

## Setup Hostnames (as root) in `Each Nodes` :
```bash
#In this example we have 3 nodes:
#192.168.2.160 k8s-control
#192.168.2.161 kworker1
#192.168.2.162 kworker2

#Control Node:
hostnamectl set-hostname k8s-control

#Worker Node 1:
hostnamectl set-hostname kworker1

#Worker Node 2:
hostnamectl set-hostname kworker2

```

## Step-2 (as root) in `All Nodes` :
```bash
printf "\n192.168.2.160 k8s-control\n192.168.2.161 kworker1\n192.168.2.162 kworker2\n" >> /etc/hosts

# on questions, just press enter
bash <(curl -sSL https://github.com/ariadata/kubernetes-cluster-setup/raw/main/container.d/1.26-on-ubuntu-22/step2-all.sh)

```

## Install Control-Plane (as root) in `Control Node` :
```bash
kubeadm init --pod-network-cidr 10.10.0.0/16 --kubernetes-version 1.26.1 --node-name k8s-control

##### Other stuffs here #####
export KUBECONFIG=/etc/kubernetes/admin.conf

kubectl create -f https://github.com/ariadata/kubernetes-cluster-setup/raw/main/container.d/1.26-on-ubuntu-22/calico-v3.25.0-tigera-operator.yaml

wget https://github.com/ariadata/kubernetes-cluster-setup/raw/main/container.d/1.26-on-ubuntu-22/calico-v3.25.0-custom-resources.yaml -O ~/custom-resources.yaml

kubectl apply -f ~/custom-resources.yaml

# get worker node commands to run to join additional nodes into cluster
kubeadm token create --print-join-command
```

## Connect Worker Nodes (as root) in `Worker Nodes` :
```bash
#Run the command from the token create output above
```

## Check Cluster Status (as root) in `Control Node` :
```bash
kubectl get nodes -o wide
```

# Used Links:
- https://youtu.be/7k9Rdlx30OY
- https://www.itsgeekhead.com/tuts/kubernetes-126-ubuntu-2204.txt
- https://www.youtube.com/watch?v=Ro2qeYeisZQ
- https://www.youtube.com/watch?v=8q9uPjDF59Q
