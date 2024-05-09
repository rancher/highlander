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

pe "git clone $GIT_URL"
pei "cd clusters"

pe "mkdir clusters"
pe "cp ../data/cluster.yaml clusters/"
pei "git add ."
pei "git commit -m \"Add cluster definition\""
pe "git push"
pei "echo \"Explore child cluster\""
