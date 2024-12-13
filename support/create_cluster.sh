#!/bin/bash

cluster_name="$1"
ip_address="$2"

echo "Creating cluster ${cluster_name} at ${ip_address}"

#  --static-ip ${ip_address}
minikube start -p ${cluster_name}  --driver docker
