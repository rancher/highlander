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

# For later use
export USERNAME=gitea_admin
export PASSWORD=admin
export NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
export NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services gitea-http)
export REPO_NAME=clusters

export GITEA_URL="http://$USERNAME:$PASSWORD@$NODE_IP:$NODE_PORT"
export GIT_URL="http://$USERNAME:$PASSWORD@$NODE_IP:$NODE_PORT/$USERNAME/$REPO_NAME.git"
