#!/usr/bin/env bash

kind create cluster --config kind-cluster-with-extramounts.yaml

kubectl rollout status deployment coredns -n kube-system --timeout=90s

export CLUSTER_TOPOLOGY=true
export EXP_CLUSTER_RESOURCE_SET=true
export EXP_MACHINE_POOL=true

clusterctl init -i docker

kubectl rollout status deployment capd-controller-manager -n capd-system --timeout=90s
