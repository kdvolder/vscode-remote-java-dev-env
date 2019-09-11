#!/bin/bash
set -e
kubectl delete secret ssh-secret
kubectl delete deployment jde
kubectl delete service jde
kubectl delete serviceAccount jde-service-account
kubectl delete clusterRoleBinding jde-cluster-admin

