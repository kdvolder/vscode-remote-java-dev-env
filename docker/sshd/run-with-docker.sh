#!/bin/bash

#docker run -it -v $HOME/.ssh/authorized_keys:/tmp/sshkeyfile --entrypoint /bin/bash kdvolder/sshd

docker run \
    -it \
    -e AUTHORIZED_KEY="$(cat $HOME/.ssh/id_rsa.pub)" \
    kdvolder/sshd

