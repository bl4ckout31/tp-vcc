#!/bin/bash

yum update -y
yum install -y epel-release
yum install -y inotify-tools

yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y install docker-ce
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
        "fixed-cidr": "172.17.0.0/24"
}
EOF
systemctl enable --now docker

ip_addr=$(ip a show eth0 | grep "inet 192" | sed -e "s/[[:space:]]\+/ /g" | cut -d " " -f 3 | cut -d "/" -f 1)

mkdir -p /home/centos/batch /srv/nfs/batch
mount --bind /home/centos/batch /srv/nfs/batch
cat >> /etc/fstab << EOF
/home/centos/batch /srv/nfs/batch none bind 0 0
EOF

cat >> /etc/nfs.conf << EOF
[nfsd]
host=$ip_addr
EOF

cat >> /etc/exports << EOF
/srv/nfs/       192.168.0.0/24(rw,sync,crossmnt,fsid=0)
/srv/nfs/batch  192.168.0.0/24(rw,sync,all_squash,anonuid=1000,anongid=1000)
EOF

exportfs -ra
systemctl enable --now nfs-server

docker swarm init --advertise-addr $ip_addr | grep "$ip_addr" > /home/centos/swarm-join.txt
