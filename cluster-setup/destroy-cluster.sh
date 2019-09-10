#!/bin/bash
source ./vars.sh
echo CLUSTER_NAME=$CLUSTER_NAME
gcloud container clusters delete $CLUSTER_NAME
