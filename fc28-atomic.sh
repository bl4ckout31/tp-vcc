#!/bin/bash

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

sed -i -e 's/--live-restore//g' /etc/sysconfig/docker
systemctl restart docker

curl http://169.254.169.254/openstack/latest/meta_data.json | python -m json.tool | grep swarm-join | cut -d '"' -f 4 | sh
