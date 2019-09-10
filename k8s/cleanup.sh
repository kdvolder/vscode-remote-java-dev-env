#!/bin/bash
set -e
kubectl delete secret ssh-secret
kubectl delete deployment jde
kubectl delete service jde