# Getting Started With Ansible

Welcome to my repository! This repo will be used for testing Ansible Playbooks and getting more familar with Ansible.

# My Lab Setup

If you're curious on how I'm conducting testing, I can tell you here.

## System 

### Windows and Linux

I'm on Window 10 Pro. For my testing environment, I'm running [Windows Subsystem for Linux (WSL)](https://learn.microsoft.com/en-us/windows/wsl/about). The specific distrobution I'm using is Kali Linux, but distro can be any.

### Python

**Python** version at the time of writing:  ***3.13***

- I highly recommend getting [Pyenv](https://github.com/pyenv/pyenv) to have better management of **Python** verisons in a convinient way. Don't worry, it's easy!

### Ansible

**Ansible** version at time of writing: ***ansible [core 2.17.5]***

## Environment

For the test servers, I am using [Docker](https://www.docker.com/) to setup test containers that will act as Ansible target hosts.

# Want to Follow Along?

If you'd like to follow along, feel free doing so and follow these steps

## Getting Ansible

To get Ansible, run:
```
# Using Python
pip install ansible

# Using Debian package manager
sudo apt install ansible
```

OR

You can create a Python Virtual Environment and use the repo's `requirements.txt`

```
# Leave this out if you want to store the venv in a different location
mkdir ~/venv

python3 -m venv ansible-playbook
source ~/venv/ansible-playbook/bin/activate # Replace if venv location is different
pip install -r requirements.txt
```


## Create Docker image

### SSH keys for containers

Generate ssh key pairs for containers:
```
ssh-keygen
Generating public/private ed25519 key pair.
Enter file in which to save the key (/home/<USER>/.ssh/id_ed25519): 
```

### Edit Dockerfile

Put the location of the generated keys into the Dockerfile located at `docker/demo-image.Dockerfile`:

***demo-image.Dockerfile***
```
# Use an Ubuntu base image
FROM ubuntu:22.04

# Install OpenSSH server and Python (required for Ansible)
RUN apt-get update && apt-get install -y openssh-server python3 && apt-get clean

# Create a directory for the SSH daemon and set up SSH keys
RUN mkdir /var/run/sshd && \
    mkdir -p /root/.ssh && \
    chmod 700 /root/.ssh

# Copy your public key into the container (replace with your key content)
# For a real setup, consider copying from a build context instead of hardcoding
COPY ansible_demo.pub /root/.ssh/authorized_keys
RUN chmod 600 /root/.ssh/authorized_keys

# Allow root login and disable password authentication
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# Expose SSH port
EXPOSE 22

# Start the SSH service
CMD ["/usr/sbin/sshd", "-D"]
```

### Create Image
After all is set and done, create the image:
```
cd /path/to/docker/
docker build -f demo-image.Dockerfile -t image-name:optional-tag
```

From here you can create as many containers as you want to act as ansible targets!

```
docker run -d image-name:optional-tag
```

## Configuring hostnames

If you look at `inventory/demo-hosts` you can see the demo hostnames I am using (these are the Docker containers):

```
[ansible-targets]
example.host1.com
example.host2.com
```
These can be whatever hostname you want to give and can be as many as you want.

In order for you to ssh into these hosts, we have to configure our `/etc/hosts` file:

```
# This file was automatically generated by WSL. To stop automatic generation of this file, add the following entry to /etc/wsl.conf:
# [network]
# generateHosts = false
...
10.0.0.1      example.host1.com
10.0.0.2      example.host2.com
...
```
The IP address is the address for each Docker container created, which you can get by doing:

```
docker inspect \
  -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' container_name_or_id
```

Follow the instructions in the file to avoid having to reconfigure this file when launching WSL :)

## Done!
The test environment is ready and you can start doing your own Ansible goodness!

# What I Have Done So Far
- Create my first ansible config file
- Created my first inventory
- Created my first playbook that install apache2 in each host
  - Created playbook that removes apache2