# Intro
This is a local argoCD tester with two kubernetes clusters

- one argoCD per cluster in created
- a third cluster for management is also created.


# Requirements 

The version indicated has been tested, on windows with the git bash shell.

 - minikube (v1.33.1) 
 - kubectl (v1.30.3)
 - helm (v3.15.2)


# What to do

To start just run the start.sh script. This will create three clusters by default. 
One of the clusters contains gitea as the git server for ArgoCD.
Each cluster will have ArgoCD installed.

The contexts will be: control, cluster-<number>
These context will let you control each cluster separately.

Once everything is setup you will be given the urls, username, and passwords for GitTea and for each ArgoCD instance.

Repos will be created locally in the repos folder. There will be an application and an infrastructure repo.

If the folders already exist (because maybe you were testing things already), then they will not be ovewritten
and will be just added to the GitTea install.

To stop the clusters execute the stop.sh script. This will delete the minikube clusters.

The repositories will stay. If you start.sh again, these repositories will be automatically
added to GitTEA and possibly to ArgoCD, and in moments you should be setup exactly as before.