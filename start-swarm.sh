#!/bin/bash

if [ $# -ne 1 ]; then
    echo "usage: $0 public_ip"
    exit 1
fi

echo "Booting Manager with ip $1..."
nova boot --flavor m1.small --image COS75 --nic net-id=c1445469-4640-4c5a-ad86-9c0cb6650cca --security-group default --key-name mykey --user-data cos75.sh COS75_${OS_USERNAME}
nova floating-ip-associate COS75_$OS_USERNAME $1

res=1
echo "Waiting for docker-swarm token and IP..."
while [ $res -ne 0 ]; do 
    sleep 1
    ssh -q centos@$1 "while [ ! -f swarm-join.txt ]; do sleep 1; done"
    res=$?
done

echo "Fetching docker-swarm token and IP..."
scp -q centos@$1:~/swarm-join.txt .
scp -q centos@$1:~/ip_manager.txt .

res=1
echo "Waiting for Nginx files..."
while [ $res -ne 0 ]; do 
    sleep 1
    ssh -q centos@$1 "while [ ! -f /tp-vcc/passwd ]; do sleep 1; done"
    res=$?
done

echo "Fetching Nginx files..."
scp -q centos@$1:/tp-vcc/ngnix.crt .
scp -q centos@$1:/tp-vcc/ngnix.key .
scp -q centos@$1:/tp-vcc/passwd .

echo "Booting workers..."
nova boot --min-count 3 --max-count 3 --flavor m1.small --image FC28atomic --nic net-id=c1445469-4640-4c5a-ad86-9c0cb6650cca --security-group default --meta ip_manager="$(cat ip_manager.txt)" --meta swarm-join="$(cat swarm-join.txt)" --user-data fc28-atomic.sh --key-name mykey FC28atomic_${OS_USERNAME}
echo "Done!"
