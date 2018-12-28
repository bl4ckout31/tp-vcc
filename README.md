# Fedora Atomic

Clone the repo:
`git clone https://github.com/bl4ckout31/tp-vcc.git `

`cd` into the new folder:
`cd tp-vcc``

Start the CentOS 7.5 manager VM and the 3 Fedora Atomic workers:
`sh start-swarm.sh <manager public IP>`
`<manager public IP>` is the Public IP that clients are going to connect to.

At the end of the script, the manager VM will be ready, but not the workers (the script end when the workers start).
Before starting the service, make sure all the workers have join the swarm:
```
ssh centos@<manager public IP>
docker node ls
```

# Bonus