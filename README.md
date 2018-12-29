# Processing Infrastructure

The Fabspace image processing as been replaced with a simple Django App with a form that takes a video and make a grayscale version of it with FFmpeg. The user can then download the result. The website will timeout if the video takes too long to process, prefer short videos.

Clone the repo:
```bash
git clone https://github.com/bl4ckout31/tp-vcc.git 
```

`cd` into the new folder:
```bash
cd tp-vcc/processing/
```

Set the password for the website:
```bash
echo "my-super-password" > password.txt
```

Start the CentOS 7.5 manager VM and the 3 Fedora Atomic workers (takes a long time):
```bash
bash start-swarm.sh <manager public IP>
```
`<manager public IP>` is the Public IP that clients are going to connect to.

At the end of the script, the manager VM will be ready, but not the workers (the script end when the workers start).
Before starting the service, make sure all the workers have join the swarm:
```bash
ssh centos@<manager public IP>
sudo docker node ls
```

When all workers are ready, it looks like this:
```bash 
sudo docker node ls
ID                            HOSTNAME                      STATUS              AVAILABILITY        MANAGER STATUS      ENGINE VERSION
5s83irozhyty134awhzst5b31 *   cos75-ens9.novalocal          Ready               Active              Leader              18.09.0
tgbxzyxc0p4h4g2ps793bprhi     fc28atomic-ens9-1.novalocal   Ready               Active                                  1.13.1
oiyaawn7b26bffhasjg0tcrvj     fc28atomic-ens9-2.novalocal   Ready               Active                                  1.13.1
5780bdnyppr82038z8ht05skf     fc28atomic-ens9-3.novalocal   Ready               Active                                  1.13.1
```

Start the service with:
```bash
sudo docker stack deploy --compose-file docker-compose.yml app
```

You can check that the service is effectively deployed:
```bash
sudo docker stack services app
ID                  NAME                MODE                REPLICAS            IMAGE               PORTS
l8cfp4d4m2oi        app_proxy           replicated          4/4                 proxy:latest        *:443->443/tcp
z6gbi9o9f033        app_django          replicated          4/4                 django-app:latest
```

You can now open https://\<manager public IP\> in your browser.
The certificate being self-signed, you will be prompt about an unsecured connection.
Username is `tp-vcc` and password what you set at the begining.