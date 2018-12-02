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
        "insecure-registries" : ["localhost:5000"]
}
EOF

echo $ip_addr > /home/centos/ip_manager.txt
systemctl enable --now docker
docker service create --name registry --p 5000:5000 registry 
#docker run -d --restart=always -p 5000:5000 --name registry registry

yum install -y docker-compose git httpd-tools
git clone https://github.com/bl4ckout31/tp-vcc.git /tp-vcc

cd /tp-vcc/app
docker build -t localhost:5000/django-app:latest .
docker push localhost:5000/django-app:latest

cd /tp-vcc/proxy
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -subj "/C=FR/ST=Toulouse/L=Toulouse/O=Université Paul Sabatier/CN=tp-vcc" -keyout nginx.key -out nginx.crt
htpasswd -cb passwd "tp-vcc" "789456123"
docker build -t localhost:5000/proxy:latest .
docker push localhost:5000/proxy:latest

docker swarm init --advertise-addr $ip_addr | grep "$ip_addr" | sed -e "s/[[:space:]]\+/ /g" > /home/centos/swarm-join.txt
