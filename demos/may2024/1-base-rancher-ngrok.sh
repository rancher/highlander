# Copyright 2024 SUSE.
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

RANCHER_HOSTNAME=${1:-$RANCHER_HOSTNAME}
if [ -z "$RANCHER_HOSTNAME" ]; then
	echo "You must pass a rancher host name"
	exit 1
fi

if [ -z "$NGROK_API_KEY" ]; then
	echo "You must pass a rancher apikey"
	exit 1
fi

if [ -z "$NGROK_AUTHTOKEN" ]; then
	echo "You must pass a rancher authtoken"
	exit 1
fi

# Check to see if the repo exists already
if [ -d ./test ]; then
	echo "The test repo directory exists already. Delete it and start again"
	exit 1
fi

RANCHER_VERSION=${RANCHER_VERSION:-v2.8.3}

BASEDIR=$(dirname "$0")

export LOCAL_IP=$(ip -4 -j route list default | jq -r .[0].prefsrc)

cat <<EOF >>./kind.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: demo
nodes:
- role: control-plane
  extraMounts:
    - hostPath: /var/run/docker.sock
      containerPath: /var/run/docker.sock
networking:
  apiServerAddress: "$LOCAL_IP"
EOF

kind create cluster --config kind.yaml

kubectl rollout status deployment coredns -n kube-system --timeout=90s

helm repo add jetstack https://charts.jetstack.io
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
helm repo add ngrok https://ngrok.github.io/kubernetes-ingress-controller
helm repo update

echo "Installaing ngrok"
helm install ngrok ngrok/kubernetes-ingress-controller \
	--set credentials.apiKey="$NGROK_API_KEY" \
	--set credentials.authtoken="$NGROK_AUTHTOKEN" \
	--wait

kubectl rollout status deployment ngrok-kubernetes-ingress-controller-manager --timeout=90s

kubectl apply -f ./data/rancher-ingress/ingress-class-patch.yaml --server-side

echo "Installaing cert-manager"
helm install cert-manager jetstack/cert-manager \
	--namespace cert-manager \
	--create-namespace \
	--version v1.12.3 \
	--set installCRDs=true \
	--wait

kubectl rollout status deployment cert-manager -n cert-manager --timeout=90s

sleep 5

echo "Installaing rancher $RANCHER_VERSION accessible at $RANCHER_HOSTNAME"
helm install rancher rancher-latest/rancher \
	--namespace cattle-system \
	--create-namespace \
	--set bootstrapPassword=rancheradmin \
	--set replicas=1 \
	--set hostname="$RANCHER_HOSTNAME" \
	--set global.cattle.psp.enabled=false \
	--version "$RANCHER_VERSION" \
	--wait

echo "Waiting for rancher $RANCHER_VERSION to be accessible at $RANCHER_HOSTNAME"
kubectl rollout status deployment rancher -n cattle-system --timeout=180s
kubectl rollout status deployment rancher-webhook -n cattle-system --timeout=180s

echo "Patching settings"
envsubst < ./data/rancher-ingress/ingress.yaml | kubectl apply -f - --server-side
envsubst < ./data/rancher-ingress/setting-patch.yaml | kubectl apply -f - --server-side --force-conflicts
kubectl apply -f ./data/rancher-ingress/rancher-service-patch.yaml --server-side

