#!/bin/bash
source ./vars.sh
gcloud beta container \
    --project "cf-spring-tools" \
    clusters create "$CLUSTER_NAME" \
    --zone "us-west1-a" \
    --no-enable-basic-auth \
    --cluster-version "1.13.7-gke.8" \
    --machine-type "custom-4-16384" \
    --image-type "COS" \
    --disk-type "pd-standard" \
    --disk-size "100" \
    --metadata disable-legacy-endpoints=true \
    --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" \
    --num-nodes "1" \
    --enable-cloud-logging \
    --enable-cloud-monitoring \
    --enable-ip-alias \
    --network "projects/cf-spring-tools/global/networks/default" \
    --subnetwork "projects/cf-spring-tools/regions/us-west1/subnetworks/default" \
    --default-max-pods-per-node "110" \
    --addons HorizontalPodAutoscaling,HttpLoadBalancing \
    --enable-autoupgrade \
    --enable-autorepair
