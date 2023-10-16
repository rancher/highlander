# Early Access Demo (using Rancher Turtles v0.1 )

## Base setup

Do this in preparation of the demo beforehand

## Start in Rancher Turtles demo dir

- Remove any kubeconfigs on local machine

```bash
 rm ~/Downloads/cluster1-capi.yaml
```

- Run the script to create the base environment

```bash
./base-rancher.sh tunnel.fruitcase.dev
```

- Wait for the **capi-controller-manager** deployment (in namespace **cattle-provisioning-capi-system**) to be created and rolled out.

- Deploy the tunnel to access the rancher cluster

```bash
rancher_deploy_inlets (or ngrok)
```

- Login in via the UI

- Bounce fleet controller (ensure fleet-agent is started)

- Disable the embedded CAPI feature in Rancher. In terminal run:

```bash
kubectl apply -f feature.yaml
``````

- Wait for Rancher pod to restart and the capi provisioning pod to be removed
- Cleanup old webhooks by running the following in a terminal:

```bash
kubectl delete mutatingwebhookconfigurations.admissionregistration.k8s.io mutating-webhook-configuration
kubectl delete validatingwebhookconfigurations.admissionregistration.k8s.io validating-webhook-configuration
```

> In your browser keep Rancher Manager but also open tabs for the docs (`https://docs.rancher-turtles.com`) and example site (`https://github.com/rancher-sandbox/rancher-turtles-fleet-example`)

## Demo

In Rancher Manager

- Show the about screen
- (if internal demo) show the embedded CAPI feature flag is disabled

### Deploy Rancher Turtles

- Explore the local cluster
- Go to App-> Repositories
- Click **Create** to add a new repository
    Name: turtles
    Index URL: `https://rancher-sandbox.github.io/rancher-turtles`
- Go to Apps->Charts
- Filter for Turtles
- Click **rancher-turtles**
- Click **Install**
  - On **Namespace** select **Create a new namespace**
  - Enter **rancher-turtles-system** as the namespace
  - Enter **rancher-turtles** as the **Name**
- Click **Next**
- In **Edit YAML** change:
  - **cert-manager.Enabled** to **false**
- Click **Install**
- In terminal watch Rancher Turtles & CAPI Operator get deployed
- Wait for the capi-controller-manager and kubeadm controllers to be deployed

### Deploy additional Docker infra provider

- Deploy the Docker infra provider. In a terminal do:

```bash
nvim capd-provider.yaml

kubectl apply -f capd-provider.yaml
```

- Wait for the docker provider to be deployed

### Add Cluster repo to fleet

- Go back to Rancher Manager
- Use menu to go to **Continuos Delivery**
- Change namespace to **fleet-local**
- Go to **Git Repos**
- Click **Add Repository**
- Fill in:
    Name: clusters
    Repository URL: get HTTPS clone url from samples reposiroty (<https://github.com/rancher-sandbox/rancher-turtles-fleet-example>)
    Branch Name: main
- Click **Next**
- Click **Create**
- Watch the resources become ready

## Import into Rancher

- use menu to go to **Cluster Management**
- Observer that the CAPI cluster isn't imported
- Mark the **default** namespace to import clusters from. In a terminal run:

```bash
kubectl label namespace default cluster-api.cattle.io/rancher-auto-import=true
```

- Go back to Rancher manager
- See that cluster get auto imported

### Connect to new cluster

- In Rancher Manager download the kubeconfig for imported cluster
- Change terminal tabs to local machine
- Run:

```bash
kubectl --kubeconfig ~/Downloads/cluster1-capi.yaml get pods -A -w --insecure-skip-tls-verify
```

### (optional) Deploy app to new cluster

- In Rancher Manager explore new cluster
- Deploy app using the UI
