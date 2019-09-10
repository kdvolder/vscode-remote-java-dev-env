#!/bin/bash
source ./vars.sh
rm -fr ~/.kube/config
gcloud container clusters get-credentials $CLUSTER_NAME