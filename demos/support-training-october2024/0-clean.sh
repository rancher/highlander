#!/usr/bin/env bash

if [ ./kind.yaml ]; then
    echo "Removing kind config file"
    rm kind.yaml
fi

kubectl delete clusters -A --wait
kind delete cluster --name demo
