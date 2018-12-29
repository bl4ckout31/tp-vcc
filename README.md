# Fedora Atomic

### Structure
Inside the `swarm` folder:

##### [cos75.sh](swarm/cos75.sh)
* Install `docker-ce`
* Change the Docker daemon settings
* Log the manager private IP in `/home/centos/ip_manager.txt`
* Start the swarm and log the join command to be executed by the workers (including the token) in `/home/centos/swarm-join.txt`

###### [fc28-atomic.sh](swarm/fc28-atomic.sh)
* Get the manager's IP and the join command from http://169.254.169.254/openstack/latest/meta_data.json
* Change the Docker daemon settings
* Execute the swarm join command

##### [start-swarm.sh](swarm/start-swarm.sh)
* Boot the manager (CentOS 7.5) with [cos75.sh](swarm/cos75.sh) as user data
* Give it the specified public IP address
* Wait for the swarm to be initialized
* Fetch the manager private IP and the join command from the VM
* Boot 3 workers (Fedora 28 Atomic) with [fc28-atomic.sh](swarm/fc28-atomic.sh) as user data and give them the informations from the previous line inside their metadata

### How to use 
Clone the repo.
```bash
git clone https://github.com/bl4ckout31/tp-vcc.git 
```

`cd` into the new folder.
```bash
cd tp-vcc/swarm/
```

Execute the [start-swarm.sh](swarm/start-swarm.sh) script.
```bash
bash start-swarm.sh <manager public IP>
``` 
With `<manager public IP>`, the Public IP that clients are going to connect to.

After the script has finished, the workers will not have joined the swarm yet.
Connect to the manager and check the swarm state.
```bash
ssh centos@<manager public IP>
sudo docker node ls
```

Eventually, every worker will have joined.
```bash 
sudo docker node ls
ID                            HOSTNAME                      STATUS              AVAILABILITY        MANAGER STATUS      ENGINE VERSION
5s83irozhyty134awhzst5b31 *   cos75-ens9.novalocal          Ready               Active              Leader              18.09.0
tgbxzyxc0p4h4g2ps793bprhi     fc28atomic-ens9-1.novalocal   Ready               Active                                  1.13.1
oiyaawn7b26bffhasjg0tcrvj     fc28atomic-ens9-2.novalocal   Ready               Active                                  1.13.1
5780bdnyppr82038z8ht05skf     fc28atomic-ens9-3.novalocal   Ready               Active                                  1.13.1
```

The swarm is now ready!

# Processing Infrastructure

The Fabspace image processing as been replaced with a simple Django App. Inside, a form takes a video and make a grayscale version of it with FFmpeg. The user can then download the result. The website will timeout if the video takes too long to process, prefer short videos.

### Structure
Inside the `processing` folder:

`cos75.sh`, `fc28-atomic.sh` and `start-swarm.sh` use the one in the previous section (**Fedora Atomic**) as a base. Thus, only additions will be describe here.

##### [cos75.sh](processing/cos75.sh)
* Get the authentication password from http://169.254.169.254/openstack/latest/meta_data.json
* Start the local registry
* Build the app Docker image and push it to the local registry
* Create the certificate and the private key for the web server
* Build th Nginx reverse proxy (for SSL and authentication handling) Docker image, with the certificate, the private key and the password file. It is then pushed to the local registry as well

##### [fc28-atomic.sh](processing/fc28-atomic.sh)
* Whitelist the manager's registry
* Pull the app and web server images from the manager's registry

##### [start-swarm.sh](processing/start-swarm.sh)
* Read the website password from `password.txt` (must be in the same folder)
* Give the password to the manager through metadata

##### `app` Folder
Contains the Django app with a `Dockerfile` to build a docker image.

##### `proxy` Folder
Contains the `nginx.conf` and `Dockerfile` to build a Ngnix reverse proxy docker image for the Django app.

### How to use
Clone the repo.
```bash
git clone https://github.com/bl4ckout31/tp-vcc.git 
```

`cd` into the new folder.
```bash
cd tp-vcc/processing/
```

Set the password for the website.
```bash
echo "my-super-password" > password.txt
```

Start the CentOS 7.5 manager VM and the 3 Fedora Atomic workers (takes a long time).
```bash
bash start-swarm.sh <manager public IP>
```
With `<manager public IP>`, the Public IP that clients are going to connect to.

After the script has finished, the workers will not have joined the swarm yet.
Connect to the manager and check the swarm state.
```bash
ssh centos@<manager public IP>
sudo docker node ls
```

Eventually, every worker will have joined.
```bash 
sudo docker node ls
ID                            HOSTNAME                      STATUS              AVAILABILITY        MANAGER STATUS      ENGINE VERSION
5s83irozhyty134awhzst5b31 *   cos75-ens9.novalocal          Ready               Active              Leader              18.09.0
tgbxzyxc0p4h4g2ps793bprhi     fc28atomic-ens9-1.novalocal   Ready               Active                                  1.13.1
oiyaawn7b26bffhasjg0tcrvj     fc28atomic-ens9-2.novalocal   Ready               Active                                  1.13.1
5780bdnyppr82038z8ht05skf     fc28atomic-ens9-3.novalocal   Ready               Active                                  1.13.1
```

Start the service with.
```bash
sudo docker stack deploy --compose-file docker-compose.yml app
```

You can check that the service is effectively deployed.
```bash
sudo docker stack services app
ID                  NAME                MODE                REPLICAS            IMAGE               PORTS
l8cfp4d4m2oi        app_proxy           replicated          4/4                 proxy:latest        *:443->443/tcp
z6gbi9o9f033        app_django          replicated          4/4                 django-app:latest
```

You can now open https://\<manager public IP\> in your browser.
The certificate being self-signed, you will be prompt about an unsecured connection.
Username is `tp-vcc` and password what you set at the begining.