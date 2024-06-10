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

. demo-magic.sh

TYPE_SPEED=40
DEMO_PROMPT="${GREEN}➜ ${CYAN}\W ${COLOR_RESET}"

. ./giteacommon.sh

pei "cd clusters"
pei "mkdir mgmt"
pei "mkdir apps"

# Create "dev cluster group
pe "cp ../data/dev_cluster_group.yaml mgmt/"
pei "git add ."
pei "git commit -m \"Create dev cluster group\""
pe "git push"

# Deploy nginx to all dev clusters

pe "cp ../data/nginx_bundle.yaml apps/"
pei "git add ."
pei "git commit -m \"Add ngnix to dev clusters\""
pe "git push"
