
helm dependency update support/control-chart 
helm install control support/control-chart --wait --kube-context control --set "gitea.gitea.admin.password=${GITEA_PASSWORD}"

kubectl get pods --context control
