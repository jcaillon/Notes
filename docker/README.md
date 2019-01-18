# Docker

## Commands

```bash
# Clean image
docker system prune

## List Docker CLI commands
docker
docker help
docker container --help

## Display Docker version and info
docker --version
docker version
docker info

## Execute Docker image
docker run hello-world
docker run -i -t ubuntu /bin/bash

## List Docker images
docker image ls

## List Docker containers (running, all, all in quiet mode)
docker container ls
docker ps
docker ps --all
docker ps -aq

# logs
docker logs containerId

## Build image from docker file
docker build -t friendlyhello .
docker build --no-cache=true -t friendlyhello .
docker image ls
docker run -p 4000:80 friendlyhello
docker run -d -p 4000:80 friendlyhello

# login to registry
docker login
docker login -u jcaillon -p mdp slnxcnaftransv01.lyon.fr.sopra:5000

# tag image (add to repository)
# remark : registry -> contains repositories -> contains images
docker tag image username/repository:tag
docker tag pythontest castafolt/pythonrepo:testpart2

# publish image
docker push username/repository:tag
docker push castafolt/pythonrepo:testpart2

# push
docker tag [OPTIONS] IMAGE[:TAG] [REGISTRYHOST/][USERNAME/]NAME[:TAG]
docker push NAME[:TAG]

docker tag oe-lnx-setup:1173 slnxcnaftransv01.lyon.fr.sopra:5000/stumps/oe-lnx-setup:1173
docker push slnxcnaftransv01.lyon.fr.sopra:5000/stumps/oe-lnx-setup:1173


# pull and run an image
docker run -p 4000:80 username/repository:tag
docker run -p 4000:80 castafolt/pythonrepo:testpart2

# just pull
docker pull castafolt/pythonrepo


docker build -t friendlyhello .  # Create image using this directory's Dockerfile
docker run -p 4000:80 friendlyhello  # Run "friendlyname" mapping port 4000 to 80
docker run -d -p 4000:80 friendlyhello         # Same thing, but in detached mode
docker container ls                                # List all running containers
docker container ls -a             # List all containers, even those not running
docker container stop <hash>           # Gracefully stop the specified container
docker container kill <hash>         # Force shutdown of the specified container
docker container rm <hash>        # Remove specified container from this machine
docker container rm $(docker container ls -a -q)         # Remove all containers
docker image ls -a                             # List all images on this machine
docker image rm <image id>            # Remove specified image from this machine
docker image rm $(docker image ls -a -q)   # Remove all images from this machine
docker login             # Log in this CLI session using your Docker credentials
docker tag <image> username/repository:tag  # Tag <image> for upload to registry
docker push username/repository:tag            # Upload tagged image to registry
docker run username/repository:tag                   # Run image from a registry


# as a service, docker-compose.yml

# A swarm is a group of machines that are running Docker and joined into a cluster
# swarm = cluster = several machines
# machine on swarm = node
# swarm init makes the current computer a swarm manager where you can run docker commands
docker swarm init

# other nodes can join the swarm and become workers
docker swarm join

# start the newly loadbalanced app
docker stack deploy -c docker-compose.yml getstartedlab
docker stack deploy --with-registry-auth -c docker-compose.yml getstartedlab # in case of a private registry
docker service ls
docker service logs serviceId

# list tasks (= containers) in a service
docker service ps getstartedlab_web

# modify docker-compose.yml (change the nb of replicas) and reload with
docker stack deploy -c docker-compose.yml getstartedlab
# no need to shutdown/restart

# shutdown stack
docker stack rm getstartedlab

# shutdown swarm
docker swarm leave --force

# a stack -> contains services -> contains containers (task/process) 


docker stack ls                                            # List stacks or apps
docker stack deploy -c <composefile> <appname>  # Run the specified Compose file
docker service ls                 # List running services associated with an app
docker service ps <service>                  # List tasks associated with an app
docker inspect <task or container>                   # Inspect task or container
docker container ls -q                                      # List container IDs
docker stack rm <appname>                             # Tear down an application
docker swarm leave --force      # Take down a single node swarm from the manager


# VMs
docker-machine create --driver virtualbox myvm1 # Create a VM (Mac, Win7, Linux)
docker-machine create -d hyperv --hyperv-virtual-switch "myswitch" myvm1 # Win10
docker-machine env myvm1                # View basic information about your node
docker-machine ssh myvm1 "docker node ls"         # List the nodes in your swarm
docker-machine ssh myvm1 "docker node inspect <node ID>"        # Inspect a node
docker-machine ssh myvm1 "docker swarm join-token -q worker"   # View join token
docker-machine ssh myvm1   # Open an SSH session with the VM; type "exit" to end
docker node ls                # View nodes in swarm (while logged on to manager)
docker-machine ssh myvm2 "docker swarm leave"  # Make the worker leave the swarm
docker-machine ssh myvm1 "docker swarm leave -f" # Make master leave, kill swarm
docker-machine ls # list VMs, asterisk shows which VM this shell is talking to
docker-machine start myvm1            # Start a VM that is currently not running
docker-machine env myvm1      # show environment variables and command for myvm1
eval $(docker-machine env myvm1)         # Mac command to connect shell to myvm1
& "C:\Program Files\Docker\Docker\Resources\bin\docker-machine.exe" env myvm1 | Invoke-Expression   # Windows command to connect shell to myvm1
docker stack deploy -c <file> <app>  # Deploy an app; command shell must be set to talk to manager (myvm1), uses local Compose file
docker-machine scp docker-compose.yml myvm1:~ # Copy file to node's home dir (only required if you use ssh to connect to manager and deploy the app)
docker-machine ssh myvm1 "docker stack deploy -c <file> <app>"   # Deploy an app using ssh (you must have first copied the Compose file to myvm1)
eval $(docker-machine env -u)     # Disconnect shell from VMs, use native docker
docker-machine stop $(docker-machine ls -q)               # Stop all running VMs
docker-machine rm $(docker-machine ls -q) # Delete all VMs and their disk images



docker run --rm --privileged --name master --network envdev --ip 172.18.0.20 --hostname master -v //var/run/docker.sock:/var/run/docker.sock -v /D/VMs/docker/python:/data -d slnxcnaftransv01.lyon.fr.sopra:5000/stumps/docker:ansible -ti /bin/bash
docker run --rm --privileged --name master --network envdev --hostname ansible -v /var/run/docker.sock:/var/run/docker.sock -v /D/VMs/docker/python:/data -d slnxcnaftransv01.lyon.fr.sopra:5000/stumps/docker:ansible -ti /bin/bash
# -v /var/run/docker.sock:/var/run/docker.sock -> allows to use the docker daemon installed on my machine instead of the docker daemon inside the stumps/docker:ansible

docker container run -d -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock portainer/portainer

docker-compose up -d
docker-compose ps
docker-compose run web env
docker-compose stop
docker-compose down --volumes
```

## Concepts

- **docker daemon** - the docker host that runs the docker engine. You interact with the docker daemon via the CLI binary `docker`, via a socker, or the HTTP API. The daemon is the server component. The client CLI can interact with both local and remote daemons. 
- **image** - a piece of software to run, the files needed to run software in a container. images are referenced by name and tag. You can think of this as a template for a container. 
- **dangling image** - no tag associated with image, often happens when rebuilding and reusing an existing tag
- **layer** - images are built up from layers that store file changes relative to a parent layer. You can think of these like commits in a git repo, in fact each command in a Docker file creates a new layer as a commit behind the scenes. 
- **tag** - a means of tagging different versions of an image, used for many purposes including versioning, and specifying different environments such as java with openjdk versus oracle jdk. Can think of like tags in git, as if every commit in git had to have a tag. Also can think of as package versions in npm. `latest` is used to denote the most recent version, used as default if no tag specified.
- **container** - an instance of an image, a directory on disk with files, a running container is an app running from this directory with a high degree of isolation. A container's directory is made up of the layers in an image, these layers are read only. The container also has a read/write layer, by default, layered on top. This is accomplished via different UnionFS filesystems: aufs, btrfs, etc. You can find the directories involved with an image by looking in `/var/lib/docker.` Every call to `docker run` starts a new container. Docker abstracts managing containers for you, you focus on what you want to run, not how to safely run it as a container.  
- **container state** - a container's state (running, exited, paused, restarting) correlates to whether or not a program is running from the container's filesystem.
- **volume** - external storage, often on the docker host, that can be mounted into containers. Because UnionFS uses copy-on-write, it's not wise to store memory mapped files (common with databases) with a UnionFS, instead use volumes. 
- **networks** - like physical networks, these allow you to isolate containers by controlling what networks they connect to. You can create user defined networks with `docker network create.`
- **repository** - a collection of tagged images, much like a github repository, often one docker repository per git repository. Also much like an npm package. There's one repository per image name. 
- **registry** - a collection of repositories, docker hub is a public/private registry, quay.io is another, much like npmjs.com. Registries are great for finding out what an image is meant to do, finding it's Dockerfile, finding it's source repository, # downloads, # stars (popularity), comments and instructions (README.md) on how to use an image.

## Security

- Prefer official images, then trusted images (means automatically built by registry, and you can see the Dockerfile used)
- Treat things manually built with suspicion
- Prefer images created by project maintainers
- Always read Dockerfile, including referenced shell scripts. Look out for http or https with insecure, also watch out for suspicious binaries.
- Know what's in the base image (hopefully it's an official image).
- Lock down to a specific tag, but remember these can be changed. Can run private registry and pull reviewed images to it.

- Run untrustworthy containers on their own network (`docker network create -d bridge X` and `docker run --net X`)
- Rebuild images you don't trust

## Isolation

- PID namespace isolation for process isolation.
- Network modes for containers
  - bridge (default) - use `docker run --net NETWORK` - container has loopback and interface to access to named networks (default connected to `bridge` network), any container on the network(s), a container is connected to, can access the bridge container
  - none - use `docker run --net none` container is isolated from all networks, only has loopback interface
  - joined - use `docker run --net container:CONTAINER` - two+ containers can share interfaces, joined container will share interfaces with existing container.
  - host - use `docker run --net host` - container binds directly to host network interface (no network isolation here, be careful)
  - within a network, there's no firewall, all ports are accessible, not just "exposed" ports
  - avoid linking, it's legacy for the default bridge network, use user defined networks to isolate container networks
  - publishing ports - binding on host allows remote access to containers
- File System isolation
  - chroot used to run container in the context of the container's directory
  - MNT namespace - essentially a union of isolated mounts forms the container's filesystem
  - UnionFS - read-only image layers, top layer is read-write
  - Volumes provide persistent storage and allow you to open up filesystem access (much like binding/publishing a port)

## Cleanup

```bash
# VMs
docker-machine ls
docker-machine stop default # put VM to sleep if not needed
docker-machine rm -y default # Blow away the whole VM and recreate it

# Containers
docker ps -a # list all containers
docker ps -f 'status=exited' # list exited containers

docker stop CONTAINER # for unused containers
docker rm -v $(docker ps -qf 'status=exited') # -q is quiet mode - just the CID returned, -v remove the volumes too (be careful)
docker rm -v $(docker ps -aq) # will remove everything not running, will error on running containers
docker rm -fv CONTAINER # nuke container SIGKILL, remove volumes too

# Images
# Growth here is often from rebuilding images and reusing tags which results in dangling images (no longer have a tag because a new image has the tag).
docker images -a # list all images
docker images -f "dangling=true"

docker rmi IMAGE # for unused images
docker rmi $(docker images -f 'dangling=true' -q)

# Volumes
# Growth here is from running containers with volumes that aren't removed when the container is removed. This sureptitiously happens when an image defines a volume and you don't know it.
docker volume ls -f "dangling=true"

docker volume rm $(docker volume ls -qf "dangling=true")

# Networks (these would be removed when no longer needed, growth here would be from docker-compose which creates a new network per project)
docker network ls
docker network rm NETWORK 
docker network rm $(docker network ls -q) # dangerous, remove all networks not used and not added by docker

# Removing images
docker rmi $(docker images -q)
```

- Most of these are commands you'd use locally and not in a production environment. This is to cleanup experiments. Be careful running some of these commands like rm -v in prod, know what you're doing.
- Growth can be avoided by running temporary containers with --rm which removes both the container and the volume when you stop it.

### Building images

```bash
*****docker build -t TAG .
docker tag IMAGE[:TAG] [REGISTRYHOST/][USERNAME/]NAME[:TAG] 
*****docker commit
*****docker cp
*****docker import FILE|URL|-
```

- [`docker build`](https://docs.docker.com/engine/reference/commandline/build/)
- [`docker commit`](https://docs.docker.com/engine/reference/commandline/commit/)
- [`docker cp`](https://docs.docker.com/engine/reference/commandline/cp/)

### Managing images

```bash
docker images

docker export CONTAINER > container.tar # export filesystem of container, NOT volumes
docker save IMAGE > image.tar # export image to archive 
docker load < image.tar.gz # load image from an archive

docker search TERM
docker search -s 3 --automated TERM # must have at least 3 stars and be automated (trusted)
docker pull IMAGE # pulls latest if no tag specified
docker login [SERVER] # login to a registry server, like docker hub
docker logout [SERVER]

# tag and push, tag tells where to push
docker tag IMAGE[:TAG] [REGISTRYHOST/][USERNAME/]NAME[:TAG]
docker push IMAGE

docker rmi IMAGE

# layer history, image sleuthing
docker history IMAGE
```

- Name Format: [REGISTRY_HOST[:REGISTRY_PORT]/]NAME[:TAG]
- [`docker export`](https://docs.docker.com/engine/reference/commandline/export/)
- [`docker images`](https://docs.docker.com/engine/reference/commandline/images/)
- [`docker load`](https://docs.docker.com/engine/reference/commandline/load/)
- [`docker pull`](https://docs.docker.com/engine/reference/commandline/pull/)
- [docker history](https://docs.docker.com/engine/reference/commandline/history/)

### Managing containers

```bash
docker help
docker help run

docker create # same as run, just doesn't start container
docker run IMAGE # create and start a container, run given command
docker run -d IMAGE # run detached
docker run -it IMAGE sh # run container with an interactive shell 
docker run --rm IMAGE # remove container, and volumes, when stopped
  # -e "VAR=VALUE" # use this to specify environment variable values, can have multiple
  # --name NAME # use this to specify an explicit name, otherwise randomly generated
  # -p "hostport:containerport" # publish a container port to a specific host port
  # -p "containerport" #publish container port to dynamic host port
  # -p "ip:hostport:containerport" # publish a container port and bind to specific ip specified (listen)
  # --net NETWORK # specify what network to connect to
  # -v "hostpath:containerpath" # mount host directory at container path, must be absolute paths
  # -v "containerpath" # mount a docker managed volume at the container path
  # --restart always # set restart value (never, always, **always-unless-stopped**)
docker ps
docker ps -a
docker ps -f "status=exited"
 # Use kitematic to find out what's running, also can find ports, volumes, env variables easily too.

docker inspect CONTAINER # verbose details about a container
docker inspect --format="{{.Mounts}}" CONTAINER
docker port CONTAINER
docker diff # list changed files in a container
docker stats [CONTAINER] # live stream of stats, CPU, MEMORY, NET, I/O

docker top CONTAINER # running processes
docker exec CONTAINER ps aux # run ps in container

docker update CONTAINER # mostly used to update constraints
docker rename CONTAINER NEWNAME

 # stop sends SIGTERM first, then after grace period sends SIGKILL
docker stop CONTAINER # can lead a container, and its volumes, to be removed if it was started with --rm
docker start CONTAINER
docker restart CONTAINER

docker pause CONTAINER
docker unpause CONTAINER

docker kill CONTAINER 
docker rm -v CONTAINER # remove a container and its volumes

docker wait CONTAINER # wait for a container to stop

docker info #system wide information, # containers
docker version
```

- Most commands allow you to pass multiple containers (for changing state, removing, etc)
- [`docker run`](https://docs.docker.com/engine/reference/commandline/run/)
- [`docker create`](https://docs.docker.com/engine/reference/commandline/create/)
- [`docker kill`](https://docs.docker.com/engine/reference/commandline/kill/)
- [docker ps](https://docs.docker.com/engine/reference/commandline/ps/)
- [docker inspect](https://docs.docker.com/engine/reference/commandline/inspect/)

## What went wrong!

### Is the container running?

```bash
# open shell in container
docker exec -it CONTAINER sh 
# run command async
docker exec -d CONTAINER COMMAND 

# attach to running container, see output, or interact with it, Ctrl+C send SIGTERM, Ctrl+P,Q detach
docker attach CONTAINER
#change detach keys if Ctrl+P,Q won't work
--detach-keys="<sequence>"
# or don't send signals to container so Ctrl+C detaches
docker attach --sig-proxy=false CONTAINER`

# follow logs
docker logs -f CONTAINER
```

- [docker exec](https://docs.docker.com/engine/reference/commandline/exec/)
- [docker attach](https://docs.docker.com/engine/reference/commandline/attach/)


### The container won't run

```bash
# Run shell instead of container's app
docker run -it CONTAINER sh
# Override entrypoint if applicable
docker run -it --entrypoint="" CONTAINER sh
```

- Find Dockerfile, see if anything stands out

### All situations:

```bash
docker logs CONTAINER`
docker logs --tail[=5] CONTAINER`
docker logs --since=""
```

- Also, check log files on volume mounts, remember excessive output is a often avoided for long lived containers.
- [docker logs](https://docs.docker.com/engine/reference/commandline/logs/)

## Managing volumes

```bash
docker volume ls

***docker volume create

docker volume inspect VOLUME # see what containers are using the volume
docker volume rm VOLUME

**review** put commands for volume containers in here
```

- two types of volumes
  - bind mount - user specifies location on host
  - docker managed mount - docker manages "anonymous" location on host
- other drivers can provide portability of volumes

## Managing networks

```bash
docker network ls

docker network inspect NETWORK # see connected containers, address range, gateway

docker network create -d bridge NETWORK # Create a user defined bridge network
docker network rm NETWORK

# Connect/disconnect containers to a network, also remember --net on docker run will connect a container
docker network connect NETWORK CONTAINER
docker network disconnect NETWORK CONTAINER
```

- User defined networks are a great way to isolate containers that you're uncertain about, don't let them communicate with other containers
- [`docker network create`](https://docs.docker.com/engine/reference/commandline/network_create/)

## NOT SURE WHERE YET

https://docs.docker.com/engine/reference/commandline/events/

## Managing VMs

```bash
# Connecting to docker daemon
docker-machine start MACHINE
eval $(docker-machine env [MACHINE])
docker-machine.exe env --shell=powershell [MACHINE] | Invoke-Expression
docker-machine.exe env --shell cmd [MACHINE]

docker-machine ls # best status command, shows all machines, active machine - means connected to via env, state of each

docker-machine env [MACHINE] # Get environment variables for a machine
docker-machine ip [MACHINE] # Get ip of machine, useful for connecting to bound ports

# working with the VM easily
docker-machine ssh [MACHINE] # ssh into a machine, magical
docker-machine scp MACHINE:/path /host/path # scp files! can flip arguments for copying either direction, this is not scp to containers, this is scp to the docker host VM
docker-machine inspect [MACHINE]

docker-machine create -d virtualbox NAME # create a new machine
docker-machine create -d virtualbox # show driver options for virtualbox
docker-machine upgrade [MACHINE]
docker-machine stop [MACHINE]
docker-machine restart [MACHINE]
docker-machine kill [MACHINE]
docker-machine rm -y [MACHINE]
```

- More docker-machine commands [here](https://docs.docker.com/machine/reference/).
- Driver options [here](https://docs.docker.com/machine/drivers)
- Most commands will use `default` as the name if no machine name specified
- docker-machine sets up secure communications with machines
- Can always look at underlying virtualization's VM library and configure advanced functionality of VMs like bridged network adapters to expose containers for remote access.
- docker-machine sets two disks in VM, one is boot2docker which is read-only, another is a mount point for docker data/volumes
- With docker-machine you can only map volumes in your USER directory (both windows/mac)
- Docker for Windows and Mac will be a new way to run containers, won't obviate docker-machine as it does other things like provision in the cloud and setup swarm clusters.
- [docker-machine env](https://docs.docker.com/machine/reference/env/)

## Creating an image interactively

1) create container from ubuntu (latest) image and run a bash terminal.  This tells docker to use the latest available ubuntu image from the default repository (usually online) run an interactive session and leave me at the bash command line. The -i -t says to keep you logged into the new container so you can work with it “interactively”  Notice that your command prompt changed to a #.  This is because you are inside the container which does not have docker installed. It is just a container with Ubuntu 16.

```bash
docker run -i -t ubuntu:latest /bin/bash
```

2) Inside the terminal install something. In my case, I am just going to do updates and install curl and save this as a Base image.  From the linux command line…

```bash
apt-get update
apt-get install curl
```

3) Exit the container terminal so we can save the current container.

```bash
exit
```

4) You will see that you now have the $ prompt.  This shows that you are no longer in the container.  You are back on the docker host.  Now we need to see what our container ID is for the container we were just working with.  the  -l [lower case L] stands for last image you created.  We need to get the container ID so we can work with it.  Take a note of your container id by executing following command :

```bash
sudo docker ps –l
```

Notice My container ID is: 7e20d89ce838

SNAGHTML159325a8

5) Now we just save the container as a new image.  In my example the new image name is ubuntu and the tagname is base. As a shortcut to typing the container id, you can select the ID and right click, Linux will automatically type it for you.

```bash
sudo docker commit 7e20d89ce838 ubuntu:base
```

Once you do this, you should get a sha256:76be…. value returned.  You now have a new image.

6) verify that you can see your new image with curl installed.

```bash
sudo docker images
```

7) You can connect to your new image by typing…

```bash
sudo docker run -it ubuntu:base
```

where  -it says you want to run an interactive session and ubuntu:base is the name:tag of the container.  If from the command prompt you type:

```bash
which curl
```

You will see output that shows the location of curl  /usr/bin/curl

8) You can exit out of the container by typing:

```bash
exit
```

9) You can change so you do not need to type sudo in front of docker commands…

```bash
sudo usermod -aG docker <AdminUser>
```

This will add the <AdminUser> to Linux Authorized users for docker replace <AdminUser> with your username must log out and log back in for it to take affect

```bash
systemctl status docker
sudo systemctl enable docker
sudo systemctl start docker
```

Now you should be able to run docker ps –a (or other docker commands) without elevating with sudo

10) Install remote desktop client. First you have to install the desktop.  Also remember you have to open port 3389 to your destination.  Connect to your container  then run

```bash
sudo apt-get install -y xubuntu-desktop
```

NOTE: you will get some pop-up boxes in the interactive session.  You can take the defaults (assuing English).  This is a very large install so it could take 20 mins or more to complete.

```bash
sudo apt-get install xrdp

echo xfce4-session >~/.xsession
```

You  could exit out and save your new image with

```bash
exit

sudo docker images
sudo docker commit <Image_ID>  ubuntu16:rdp
```

Connect back to your new container

```bash
sudo docker run -it ubuntu16:rdp
```

11) Let’s install something harder… R-Studio (https://www.datascienceriot.com/how-to-install-r-in-linux-ubuntu-16-04-xenial-xerus/kris/)

```bash
sudo echo “deb http://cran.rstudio.corsm/bin/linux/ubuntu xenial/” | sudo tee -a /etc/apt/sources.list

gpg –keyserver keyserver.ubuntu.com –recv-key E084DAB9
gpg -a –export E084DAB9 | sudo apt-key add –

# NOTE:  Install R-Base
sudo apt-get update
sudo apt-get install r-base r-base-dev -y

# NOTE:  Install R-Studio
sudo apt-get install gdebi-core -y
wget https://download1.rstudio.org/rstudio-0.99.896-amd64.deb
sudo gdebi -n rstudio-0.99.896-amd64.deb
rm rstudio-0.99.896-amd64.deb
```

12) You can remove an image with the docker rmi <image> command.  docker rm <container> to remove a container. However, containers built on other containers/images cannot  be removed as a container unlike a VM is not fully self contained.  It relies on the base container as it’s image.   Remember to show containers docker ps -a.  To show images use docker images.  The difference between the two is an <image> is a saved <container>.

```bash
docker rmi <image>
docker rm <container>
```

13) You can rename an image using docker tag.  This is especially helpful if you have many like images. tags are often used as a versioning tool.  However you create any number of naming conventions with both names and tags.

```bash
docker tag d583c3ac45fd myname/server:latest
docker tag ubuntu:base ubuntu16base:mytag
```

14) Docker auto assigns each container a name. You can rename a container using docker rename CONTAINER NEW_NAME

```bash
docker rename serene_pare mybase16
```