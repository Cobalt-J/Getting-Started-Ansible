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