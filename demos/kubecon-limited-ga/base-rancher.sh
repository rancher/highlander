#!/usr/bin/env bash

# Copyright 2023 SUSE.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

RANCHER_HOSTNAME=$1
if [ -z "$RANCHER_HOSTNAME" ]; then
	echo "You must pass a rancher host name"
	exit 1
fi

RANCHER_VERSION=${RANCHER_VERSION:-v2.8.1}

NGROK_AUTHTOKEN=""
NGROK_API_KEY=""

BASEDIR=$(dirname "$0")

kind create cluster --config kind-cluster-with-extramounts.yaml

kubectl rollout status deployment coredns -n kube-system --timeout=90s

helm repo add jetstack https://charts.jetstack.io
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
helm repo add ngrok https://ngrok.github.io/kubernetes-ingress-controller
helm repo update

helm install ngrok ngrok/kubernetes-ingress-controller \
	--set credentials.apiKey="$NGROK_API_KEY" \
	--set credentials.authtoken="$NGROK_AUTHTOKEN" \
	--wait

kubectl rollout status deployment ngrok-kubernetes-ingress-controller-manager --timeout=90s

kubectl apply -f ./rancher-ingress/ingress-class-patch.yaml --server-side

helm install cert-manager jetstack/cert-manager \
	--namespace cert-manager \
	--create-namespace \
	--version v1.12.3 \
	--set installCRDs=true \
	--wait

kubectl rollout status deployment cert-manager -n cert-manager --timeout=90s

helm install rancher rancher-latest/rancher \
	--namespace cattle-system \
	--create-namespace \
	--set bootstrapPassword=rancheradmin \
	--set replicas=1 \
	--set hostname="$RANCHER_HOSTNAME" \
	--set global.cattle.psp.enabled=false \
	--version "$RANCHER_VERSION" \
	--wait

kubectl rollout status deployment rancher -n cattle-system --timeout=180s

kubectl apply -f ./rancher-ingress/ingress.yaml
kubectl apply -f ./rancher-ingress/rancher-service-patch.yaml --server-side
