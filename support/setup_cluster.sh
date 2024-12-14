#!/bin/bash

cluster_name="$1"
httpPort="$2"
httpsPort="$3"

echo "Installing ArgoCD on : $cluster_name"
kubectl create namespace argocd --context "${cluster_name}"
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml --context "${cluster_name}"
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s --context "${cluster_name}"
echo helm install "argo" support/argo-chart --kube-context "$cluster_name" --set httpPort="$httpPort" --set httpsPort="$httpsPort" --wait
helm install "argo" support/argo-chart --kube-context "$cluster_name" --set httpPort="$httpPort" --set httpsPort="$httpsPort" --wait
kubectl label secret argocd-secret -n argocd "cluster=${cluster_name}" --overwrite --context "${cluster_name}"
kubectl apply -n argocd --context "${cluster_name}" -f support/initial-manifests/initial-application.yaml
