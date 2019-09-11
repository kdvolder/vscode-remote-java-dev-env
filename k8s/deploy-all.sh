#!/bin/bash
set -e
./create-secret.sh
kubectl create -f service-account.yml
kubectl create -f javadev-deployment.yml
