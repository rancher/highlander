#!/usr/bin/env bash

if [ -d ./clusters ]; then
    echo "Removing test repo dir"
    rm -rf clusters/
fi

if [ -d ./keys ]; then
    echo "Removing ssh keys dir"
    rm -rf keys/
fi

if [ ./ca.pem ]; then
    echo "Removing CA file"
    rm ca.pem
fi

if [ ./child1.kubeconfig ]; then
    echo "Removing child1 kubeconfig file"
    rm child.kubeconfig
fi

if [ ~/Downloads/cluster1-capi.yaml ]; then
    echo "Removing Rancher child kubeconfig"
    rm ~/Downloads/cluster1-capi.yaml
fi

if [ ./kind.yaml ]; then
    echo "Removing kind config file"
    rm kind.yaml
fi

if [ ./repo.yaml ]; then
    echo "Removing repo file"
    rm repo.yaml
fi

kind delete cluster --name demo
kind delete cluster --name cluster1
