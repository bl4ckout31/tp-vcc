#!/bin/bash

set -x
exec >> /out.log 2>> /err.log

curl http://169.254.169.254/openstack/latest/meta_data.json > /tmp/meta_data.json
ip_manager=$(cat /tmp/meta_data.json | python -m json.tool | grep ip_manager | sed -e "s/[[:space:]]\+/ /g" | cut -d "\"" -f 4)

sed -ie 's/--live-restore//g' /etc/sysconfig/docker
echo "DOCKER_NETWORK_OPTIONS=--mtu=1450 --bip=\"172.17.0.1/24\" --fixed-cidr=\"172.17.0.0/24\"" > /etc/sysconfig/docker-network

cat > /etc/containers/registries.conf << EOF
[registries.search]
registries = ['docker.io', 'registry.fedoraproject.org', 'quay.io', 'registry.access.redhat.com']

[registries.insecure]
registries = ['localhost:5000']

[registries.block]
registries = []
EOF

systemctl restart docker

cat /tmp/meta_data.json | python -m json.tool | grep swarm-join | cut -d '"' -f 4 | sh
