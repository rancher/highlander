# Rancher Turtles Demo - May 2024

## Base setup

> Do this in preparation of the demo beforehand. 

1. Ensure the demo directory is in a **clean** state by running the following:

```bash
./0-clean.sh
```

2. Rancher Manager cluster (v2.8.3) using either the manual or scripted method in the sections below

### Create a new Rancher cluster - ngrok

- Before creating the demo cluster, you need to provide the `NGROK_AUTHTOKEN` and `NGROK_API_KEY` that will be used to configure the endpoint.
    - Edit `base-rancher.sh`.
- The ingress will then be configured to access Rancher UI.
    - Edit `rancher-ingress/ingress.yaml` and specify your hostname.
- Run the script to create the base environment. Substitute `<rancher-hostname>` with the `ngrok` endpoint. You can get this from the [ngrok dashboard](https://dashboard.ngrok.com/cloud-edge/endpoints).

```bash
./1-base-rancher-ngrok.sh <rancher-hostname>
```
### Create a new Rancher cluster - custom tunnel

- Run the following to create the manager cluster

```bash
./1-base-rancher.sh <rancher-hostname>
```

- Setup ngrok, inlets-pro or another tunneling solution to access the Rancher Manager cluster on the specified **<rancher-hostname>**

### Post Rancher Setup

The methods above will create a Rancher instance with `embedded-cluster-api` enabled, so we wait for the **capi-controller-manager** deployment (in namespace **cattle-provisioning-capi-system**) to be created and rolled out.

Then do the following:

- Log in via the UI
- Bounce fleet controller (ensure fleet-agent is started)
- Disable the embedded CAPI feature in Rancher. In terminal run:

```bash
kubectl apply -f ./data/feature.yaml
```

- Wait for Rancher pod to restart and the capi provisioning pod to be removed
- Cleanup old webhooks by running the following in a terminal:

```bash
kubectl delete mutatingwebhookconfigurations.admissionregistration.k8s.io mutating-webhook-configuration
kubectl delete validatingwebhookconfigurations.admissionregistration.k8s.io validating-webhook-configuration
```

> In your browser keep Rancher Manager but also open tabs for the docs (`https://docs.rancher-turtles.com`) and example site (`https://github.com/rancher-sandbox/rancher-turtles-fleet-example`)

### Setup Gitea

As this demo has elements of GitOps an instance of Gitea needs to be setup in the cluster:

- Run the following command to setup gitea

```bash
./2-install-gitea.sh
```

- Log into gitea and go to the repo that was created.

## Demo

In Rancher Manager

- Show the about screen
- (if internal demo) show the embedded CAPI feature flag is disabled

### Deploy Rancher Turtles

- Explore the local cluster
- Go to App-> Repositories
- Click **Create** to add a new repository
    Name: turtles
    Index URL: `https://rancher.github.io/turtles`
- Go to Apps->Charts
- Filter for Turtles
- Click **rancher-turtles**
- Click **Install**
- Click **Next**
- Click **Edit YAML**
- Set `rancherTurtles.features.propogate-labels.enabled` to **true**
- Click **Install**
- In terminal watch Rancher Turtles & CAPI Operator get deployed
- Under Apps->Installed Apps: select `rancher-turtles-system` from the list of namespaces (top) to see the installed app
- Wait for the capi-controller-manager and kubeadm controllers to be deployed

### Deploy the UI extension

1. In the side bar click **Extensions**
3. Click **Enable**
4. On the ***Enable Extension Support*** popup select **OK**
5. Wait for the **Extensions** screen to load, it should have the **Installed**, **Available**, **Updates** and **All** tabs
6. Click the the "3 dots" button to the right and click **Manage Repositories**
7. Click **Create**
8. Enter the following:
   - Name: `turtlesui`
   - Target: Select Git
   - Git Repo URL: `https://github.com/rancher/capi-ui-extension`
   - Branch: `gh-pages`
9. Click **Create**
10. Wait for the line item for **turtlesui** ti have a state of **Active**
11. In the side bar click **Extensions**
12. Ensure **Available** is selected
13. Click **Install** form **Rancher Turtles UI***
14. It should select the latest version by default
15. Wait for the extension to be installed
16. Click the **Reload** button

## Enable automatic import

This will enable automatic import of CAPI clusters from the default namespace

- Explore local cluster
- Click **Projects/Namespaces**
- Click "3 dots" for default namespace
- Select **Enable CAPI Automatic Import**

### Deploy Docker infra provider via UI

- In Rancher Manager using the sidebar click **Cluster Management**
- Click **CAPI**
- Select **Providers**
- Click **Create**
- Click **Docker**
- Enter the following:
    Namespace: **default**
    Name: **docker**
- Click **Create**
- Wait for it to be ready
- Show in k9s that the provider has been deployed

### Deploy additional providers via cli

> This could be done using GitOps or UI if you wanted

- Run the following:

```bash
kubectl apply -f ./data/kubeadm-bootstrap.yaml
kubectl apply -f ./data/kubeadm-control-plane.yaml
```

### Add ClusterClass to repo

- Run the following to add a sample  clusterclass (and crs) to the cluster

```bash
kubectl apply -f ./data/clusterclass.yaml
kubectl apply -f ./data/crs.yaml
```

- Use the Rancher Manager UI tio via the ClusterClass and show you can create a cluster from the UI

## Create cluster via GitOps

- Run the following to commit the cluster definition to git:

```bash
./3-add-cluster.sh
```

### Add management repo to Rancher

- Go back to Rancher Manager
- Use menu to go to **Continuos Delivery**
- Change namespace to **fleet-local**
- Go to **Git Repos**
- Click **Add Repository**
- Fill in:
    Name: management
    Repository URL: get the http url from the gitea window
    Branch Name: main
    Git Authentication: **basic-auth-secret**
- Click **Next**
- Click **Create**
- Watch the resources become ready

### Wait for cluster to be imported and then connect

- in rancher manager download the kubeconfig

```bash
k9s --kubeconfig ~/Downloads/cluster1-capi.yaml --insecure-skip-tls-verify
```

### Deploy an application via GitOps

- switch back to main window/tab
- Run the following:

```bash
./4-deploy-app-gitops.sh
```

### Scale the control plane

- In Gitea edit the cluster definition
- Change control plane replcas to 3 and commit

### Upgrade the control plane

- In Gitea edit the cluster definition
- Change version to `v1.28.0`
