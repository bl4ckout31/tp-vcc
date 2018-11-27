#!/bin/bash

sed -i -e 's/--live-restore//g' /etc/sysconfig/docker
systemctl restart docker

curl http://169.254.169.254/openstack/latest/meta_data.json | python -m json.tool | grep swarm-join | cut -d '"' -f 4 | sh
