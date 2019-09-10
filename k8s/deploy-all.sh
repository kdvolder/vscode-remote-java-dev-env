#!/bin/bash
set -e
./create-secret.sh
kubectl create -f javadev-deployment.yml
