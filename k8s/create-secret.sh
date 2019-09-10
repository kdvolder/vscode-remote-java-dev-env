#!/bin/bash
set -e
kubectl create secret generic ssh-secret --from-file=AUTHORIZED_KEY=$HOME/.ssh/id_rsa.pub
