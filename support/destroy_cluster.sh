#!/bin/bash

cluster_name="$1"

minikube delete -p ${cluster_name} 