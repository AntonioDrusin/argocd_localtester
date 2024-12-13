#!/bin/bash
source ./config.sh

if [ -f /tmp/minikube_started_pid ]; then
    for pid in $(cat /tmp/minikube_started_pid); do
      if [ -n "$pid" ]; then
        kill $pid
        echo "Killed process $pid"
      fi
    done
else
    echo "PID file not found."
fi

source ./support/cleanup_control.sh

for cluster_name in "${!clusters[@]}"; do
  echo "Removing cluster: $cluster_name"
  ./support/destroy_cluster.sh "$cluster_name" &
done



wait