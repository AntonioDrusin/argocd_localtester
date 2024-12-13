#!/bin/bash

GITEA_PASSWORD=$(openssl rand -base64 12 | tr -d '/+=' | head -c 12)
export GITEA_USER="gitadmin"
export GITEA_PASSWORD

n=2
declare -A clusters


clusters["control"]="192.68.65.99"
for i in $(seq 0 $((n-1))); do
    cluster_name="cluster-$i"
    cluster_ip="192.168.65.$((100+i))"  # Example IP address, modify as needed
    clusters[$cluster_name]=$cluster_ip
done