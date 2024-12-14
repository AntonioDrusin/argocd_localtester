#!/bin/bash
SECONDS=0  
source ./config.sh

declare -a PROCESSES
for cluster_name in "${!clusters[@]}"; do
  echo "Creating cluster: $cluster_name, IP Address: ${clusters[$cluster_name]}"
  ./support/create_cluster.sh "$cluster_name" ${clusters[$cluster_name]} &
  PROCESSES+=($!)
done

for PROCESS in "${PROCESSES[@]}"; do
    wait $PROCESS
done

echo "Creating tunnels"
echo "" > /tmp/minikube_started_pid
for cluster_name in "${!clusters[@]}"; do
  minikube tunnel -p "$cluster_name" > /tmp/minikube_control_tunnel.log 2>&1 &  
  echo $! >> /tmp/minikube_started_pid
done

# Installs argoCD on each cluster
declare -a PROCESSES
source ./support/setup_control.sh &
PROCESSES+=($!)

httpPort=8100
httpsPort=8400
for cluster_name in "${!clusters[@]}"; do
    ./support/setup_cluster.sh "$cluster_name" $httpPort $httpsPort &
    PROCESSES+=($!)
    httpPort=$((httpPort +1))
    httpsPort=$((httpsPort +1))
done


echo "Waiting for all cluster setup do be complete"
for PROCESS in "${PROCESSES[@]}"; do
    echo Waiting for "$PROCESS"
    wait "$PROCESS"
done


echo "Creating gitea API token"
mkdir -p api
GITEA_POD_NAME=""

while [[ -z "$GITEA_POD_NAME" ]]; do
  GITEA_POD_NAME=$(kubectl get pods --selector=app.kubernetes.io/name=gitea -n gitea --context control -o jsonpath="{.items[0].metadata.name}")
  if [[ -z "$GITEA_POD_NAME" ]]; then
    echo "Waiting for Gitea pod to be available..."
    sleep 5
  fi
done
echo "Pod with GITEA: ${GITEA_POD_NAME}"
kubectl exec "$GITEA_POD_NAME" -n gitea --context control -c gitea -- gitea admin user generate-access-token -u gitadmin --raw --scopes all --token-name gitea2 > /tmp/gitea_api_token

# Create the repositories

echo "Creating Gitea repositories"
mkdir -p repos
create_gitea_repo() {
  local repo_name=$1
  local gitea_api_token
  gitea_api_token=$(cat /tmp/gitea_api_token)

  curl -X POST "http://localhost:3000/api/v1/user/repos" \
      -H "Content-Type: application/json" \
      -H "Authorization: token ${gitea_api_token}" \
      -d '{
          "name": "'"${repo_name}"'",
          "auto_init": true,
          "private": false
      }'
      
  if [[ -d "repos/$repo_name" ]]; then
    echo "Pushing repository repos/$repo_name from gitea"
    pushd "repos/$repo_name" || exit
    for remote in $(git remote); do
        echo "Removing remote: $remote"
        git remote remove "$remote"
    done
    git remote add gitea "http://gitadmin:${GITEA_PASSWORD}@localhost:3000/gitadmin/$repo_name.git"
    git push --set-upstream --force gitea main
    git push gitea main
    popd || exit
  else
    echo "Pulling repository $repo_name from gitea"
    pushd "repos" || exit
    git clone "http://localhost:3000/gitadmin/$repo_name"
    popd || exit
  fi
}

create_gitea_repo "infrastructure"
create_gitea_repo "application"

# Then copy it out

echo "Gitea URL: http://localhost:3000"
echo "Gitea User: gitadmin"
echo "Gitea Password: ${GITEA_PASSWORD}"
httpPort=8100
for cluster_name in "${!clusters[@]}"; do
  # parse the secretbash 
  echo "ArgoCD url: http://localhost:${httpPort}"
  httpPort=$((httpPort +1))
  echo "ArgoCD ${cluster_name} User: admin"
  echo "ArgoCD ${cluster_name} Password: $(kubectl get secret argocd-initial-admin-secret --context "$cluster_name" -n argocd -o jsonpath="{.data.password}" | base64 --decode)"  
done

echo "Total execution time: $SECONDS seconds"