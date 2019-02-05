# Docker workshop 1: introduction to docker

To explain docker, start from the need behind it.

Example scenario: I want to serve a web application (written in .js). I have no idea what to use to serve static files (I need an HTTP server: apache, tomcat, nginx?). Nginx sounds cool.

## Challenges to run a software

- Find something to download
- Do I trust this software? Do I trust the link
- Find the right release (linuxdistrib/windows, which version of the OS, 32/64bits)
- Understand the installation process (.exe to install? .zip to unzip? Variables to create? So on)
- Do I need to install dependencies?
- How do i start it?
- In the end what was install on my computer?
- Can it break if I update my OS or dependencies and so on…

## Installation on windows

Doc: https://docs.docker.com/docker-for-windows/install/.

Requirements:

- Linux/windows vm
- Hyper-v
- Minimal conf (win10 update) + **CAN NOT USE SIMULTANEOUSLY WITH VMWARE!**

## Run nginx (engine X)

```bash
docker search nginx
docker pull nginx:alpine
docker create nginx:alpine
docker ps -a
docker start ID
docker stop ID
docker rm ID
docker rmi nginx:alpine
```

Talk about tags (latest by default) and registries: https://hub.docker.com/_/nginx.

## Open a shell on a running container

```bash
docker exec -it CONTAINERID
export HTTP_PROXY=http://lyon.proxy.corp.sopra:8080
apk update
apk add curl
curl http://localhost:80
```

## Show our container ip

- ip a s
- Docker inspect CONTAINER
- http://CONTAINER_IP:80

## Access a container port

Recreate with `-p 80:80`.

## Docker run

![](images/2019-01-18-16-22-07.png)

- STANDARD OUTPUT = log of the app
- CTRL+C without - it option and with - it option
- CTRL+PQ to detach from - it

Show the persistance of data while the container is alive (even stopped).

## Create an image

### Interactively

Copying files from containers nginx -d and copy files to the container /usr/share/nginx/html

```bash
Docker run -d --name ng -p 80:80 nginx:alpine
docker cp .\solitaire\app\. ng:/usr/share/nginx/html
#Create an image interactively by doing stuff inside the container and saving container as an image (docker commit)
Docker commit ng solitaire:nginx
Docker image ls
```

### Create from dockerFile

```DockerFile
FROM nginx:alpine
COPY app\ /usr/share/nginx/html
```

`Docker build -t solitaire:build .`

`docker save solitaire:nginx -o solitaire.tar`

**Image -> Container -> Image.**

Explain the layers.

![](images/2019-01-18-16-25-31.png)

### Make the container access the host filesystem

`docker run --rm --name ng -v C:\data\docker\demo\solitaire\app:/usr/share/nginx/html:ro -p 8080:80 -d nginx:alpine`

## Run CLI

Run CLI tool: https://github.com/rg3/youtube-dl.

Requirements:

- python
- ffmpeg
- youtube-dl

```DockerFile
FROM python:alpine

RUN pip install --upgrade youtube-dl \
 && mkdir -p /download

RUN apk upgrade -U \
 && apk add ca-certificates ffmpeg libva-intel-driver \
 && rm -rf /var/cache/*

WORKDIR /download

ENTRYPOINT ["youtube-dl"]
```

build it:

```bash
docker build -t youtube-dl .
```

run it:

```bash
docker run --rm --name youtube-dl -v E:/Download/musiques:/download youtube-dl --yes-playlist --extract-audio --audio-format mp3 -o %(title)s.%(ext)s --download-archive archive.txt "myplaylisturl"
```

## TODO NEXT

- Show portainer
- Switch to windows containers (show of they are separated list images/containers)
- Docker inspect to get the ip of the container (don't use the mapped port if using this ip, use the actual container port)
- Isolation: process/filesystem/network
- Using docker for cmd line tools like tar
- Mounting volumes (bind-mount = from host file system) -v
- Docker volume ls, named volume (managed volume) -v NAME:/path/in/container
- Stop all containers: Docker stop $(docker ps -q)
- Docker compose file (create a network so that containers can talk to each other + DNS to ping containers with their service name)
- Docker compose up/down inspect
- Docker network (bridge by default)
- Docker-compose exec CONTAINER bash
- Docker network inspect DOCKERCOMPOSEPROJECT_default
- Docker run --it --rm --net PROJECT_default alpine sh / ping HOST / 
- logging drivers
- how to log properly
- fluentd elasticsearch kibana
- health check

Start on windows images
show where the layers are stored
talk about volumes
show where they are stored
container names
switch to linux containers
not the same place to see images/volumes?
mobi linux vm

```bash
# Run this from your regular terminal on Windows / MacOS:
docker container run --rm -it -v /:/host alpine

# Once you're in the container that we just ran, run this:
chroot /host
```