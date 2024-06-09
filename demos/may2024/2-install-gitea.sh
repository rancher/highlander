#!/usr/bin/env bash

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

# Create keys for admin user
mkdir keys
ssh-keygen -f keys/admin

helm repo add gitea-charts https://dl.gitea.com/charts/
helm install gitea gitea-charts/gitea --values ./data/gitea_values.yaml --wait

# Get common git stuff
. ./giteacommon.sh
#export USERNAME=gitea_admin
#export PASSWORD=admin
#export NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
#export NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services gitea-http)
#export REPO_NAME=clusters

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

kubectl create secret generic basic-auth-secret -n fleet-local --type=kubernetes.io/basic-auth --from-literal=username=$USERNAME --from-literal=password=$PASSWORD

echo "kind: GitRepo
apiVersion: fleet.cattle.io/v1alpha1
metadata:
  name: fleet-repo
  namespace: fleet-local
spec:
  repo: http://$NODE_IP:$NODE_PORT/$USERNAME/$REPO_NAME.git
  branch: main
  forceSyncGeneration: 1
  clientSecretName: basic-auth-secret
" | kubectl apply -f -

xdg-open $GITEA_URL
