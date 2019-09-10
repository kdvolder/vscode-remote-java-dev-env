#!/bin/bash
set -e

# Generates new ssh host keys every time the container is started
# Maybe instead this could be configured into a k8s configmap
rm -fr /etc/ssh/ssh_host*key
ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
ssh-keygen -f /etc/ssh/ssh_host_ecdsa_key -N '' -t ecdsa
ssh-keygen -f /etc/ssh/ssh_host_ed25519_key -N '' -t ed25519

if [ ! -z "$AUTHORIZED_KEY" ]; then
    mkdir -p /root/.ssh
    echo "$AUTHORIZED_KEY" > /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
    cat /root/.ssh/authorized_keys
else
    echo "Need AUTHORIZED_KEY environment variable"
    exit 999
fi

mkdir -p /run/sshd
/usr/sbin/sshd -D