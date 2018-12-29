#!/bin/bash

set -x
exec >> /out.log 2>> /err.log

yum update -y
yum install -y epel-release

yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce

ip_addr=$(ip a show eth0 | grep "inet 192" | sed -e "s/[[:space:]]\+/ /g" | cut -d " " -f 3 | cut -d "/" -f 1)
mkdir /etc/docker
cat > /etc/docker/daemon.json << EOF
{
        "log-driver": "journald",
        "data-root": "/dockyard",
        "storage-driver": "overlay2",
        "storage-opts": [
                "overlay2.override_kernel_check=true"
        ],
        "mtu": 1450,
        "bip": "172.17.0.1/24",
        "fixed-cidr": "172.17.0.0/24",
        "insecure-registries" : ["$ip_addr:5000"]
}
EOF

echo $ip_addr > /home/centos/ip_manager.txt
systemctl enable --now docker

docker swarm init --advertise-addr $ip_addr | grep "$ip_addr" | sed -e "s/[[:space:]]\+/ /g" > /home/centos/swarm-join.txt
