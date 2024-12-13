
helm dependency update support/control-chart 
helm install control support/control-chart --wait --kube-context control --set "gitea.gitea.admin.password=${GITEA_PASSWORD}" --create-namespace --namespace gitea

kubectl get pods --context control
