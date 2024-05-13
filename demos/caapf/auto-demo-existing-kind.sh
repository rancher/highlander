#!/usr/bin/env bash

# Check to see if the repo exists already
# NOTE: this is a duplicate in case this script is run directly
if [ -d ./test ]; then
  echo "The test repo directory exists already. Delete it and start again"
  exit 1
fi

# Create keys for admin user
# mkdir keys
# ssh-keygen -f keys/admin

# Add chart repos we are going to use
pei "helm repo add gitea-charts https://dl.gitea.com/charts/"
pei "helm repo add fleet https://rancher.github.io/fleet-helm-charts/"
pei "helm repo add capi-operator https://kubernetes-sigs.github.io/cluster-api-operator"
pe "helm repo update"

# get settings required for fleet
kubectl config view -o json --raw | jq -r '.clusters[].cluster["certificate-authority-data"]' | base64 -d >ca.pem
API_SERVER_URL=$(kubectl config view -o json --raw | jq -r '.clusters[] | select(.name=="kind-caapf-demo").cluster["server"]')
API_SERVER_CA="ca.pem"

# Install Fleet
pe "helm -n cattle-fleet-system install --create-namespace --wait fleet-crd fleet/fleet-crd"
pe "helm install --create-namespace -n cattle-fleet-system --set apiServerURL=\"$API_SERVER_URL\" --set-file apiServerCA=\"$API_SERVER_CA\" fleet fleet/fleet --wait"

# Install Gitea
pe "helm install gitea gitea-charts/gitea --values gitea_values.yaml --wait"

# For later use
export USERNAME=gitea_admin
export PASSWORD=admin
export NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
export NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services gitea-http)
export REPO_NAME=test

# Add SSH key to Gitea user
PUB_KEY=$(cat keys/admin.pub)
curl \
  -X POST "http://$NODE_IP:$NODE_PORT/api/v1/user/keys" \
  -H "accept: application/json" \
  -u $USERNAME:$PASSWORD \
  -H "Content-Type: application/json" \
  -d "{\"key\": \"$PUB_KEY\", \"read_only\": false, \"title\": \"key1\" }" \
  -i

# Setup gitea user
curl \
  -X POST "http://$NODE_IP:$NODE_PORT/api/v1/user/repos" \
  -H "accept: application/json" \
  -u $USERNAME:$PASSWORD \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"$REPO_NAME\", \"auto_init\": true}" \
  -i

# Install cert-manager
pe "kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.12.0/cert-manager.crds.yaml"
pe "helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.12.0"

# Install CAPI operator
pe "helm install capi-operator capi-operator/cluster-api-operator --create-namespace -n capi-operator-system --wait"

# Add git auth secret
pe "kubectl create secret generic basic-auth-secret -n fleet-local --type=kubernetes.io/basic-auth --from-literal=username=$USERNAME --from-literal=password=$PASSWORD"

# Add our git repo
cat <<EOF >>./repo.yaml
kind: GitRepo
apiVersion: fleet.cattle.io/v1alpha1
metadata:
  name: fleet-repo
spec:
  repo: http://$NODE_IP:$NODE_PORT/$USERNAME/$REPO_NAME.git
  branch: main
  forceSyncGeneration: 1
  clientSecretName: basic-auth-secret
EOF

pe "$EDITOR repo.yaml"
pe "kubectl apply -n fleet-local -f repo.yaml"

export GITEA_URL="http://$USERNAME:$PASSWORD@$NODE_IP:$NODE_PORT"
pe "xdg-open $GITEA_URL"

export GIT_URL="http://$USERNAME:$PASSWORD@$NODE_IP:$NODE_PORT/$USERNAME/$REPO_NAME.git"

# Clone the test repo
pe "git clone $GIT_URL"
pei "cd test"

# Install CAPI providers
# equivalent of doing clusterctl init
pe "mkdir mgmt"
pe "cp ../data/providers.yaml mgmt/"
pei "git add ."
pei "git commit -m \"Add CAPI providers\""
pe "git push"

pe "kubectl rollout status deployment capi-controller-manager -n default --timeout=90s"

# Add kindnet CNI using CRS
pe "mkdir crs"
pe "cp ../data/crs.yaml crs/"
pei "git add ."
pei "git commit -m \"Add kindet crs\""
pe "git push"

# Install the Fleet addon provider
pe "cp ../data/addon_provider.yaml mgmt/"
pei "git add ."
pei "git commit -m \"Add fleet addon provider providers\""
pe "git push"
pe "kubectl rollout status deployment caapf-controller-manager -n default --timeout=90s"

# Add the cluster class
pe "mkdir classes"
pe "cp ../data/clusterclass.yaml classes/"
pei "git add ."
pei "git commit -m \"Add clustercluster definition\""
pe "git push"

# Create a child cluster
pe "mkdir clusters"
pe "cp ../data/cluster1.yaml clusters/"
pei "git add ."
pei "git commit -m \"Add cluster definition\""
pe "git push"
pei "echo \"Explore child cluster\""

# Create "dev cluster group
pe "cp ../data/dev_cluster_group.yaml mgmt/"
pei "git add ."
pei "git commit -m \"Create dev cluster group\""
pe "git push"
pei "echo \"Explore cluster group\""

# Deploy nginx to all dev clusters
pei "mkdir apps"
pe "cp ../data/nginx_bundle.yaml apps/"
pei "git add ."
pei "git commit -m \"Add ngnix to dev clusters\""
pe "git push"

# Add bundle that uses the cluster group that was automatically created
# by the addon provider

# Deploy nginx to all dev clusters
pe "cp ../data/podinfo_bundle.yaml apps/"
pei "git add ."
pei "git commit -m \"Add podinfo to quickstart group\""
pe "git push"

pe "echo \"Explore git and see how the app was deployed\""

# Add second cluster and watch everything get deployed
pe "cp ../data/cluster2.yaml clusters/"
pei "git add ."
pei "git commit -m \"Add 2nd cluster definition\""
pe "git push"
pei "echo \"Explore child cluster\""
