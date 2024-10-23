1. Ensure the demo directory is in a **clean** state by running the following:

```bash
./0-clean.sh
```

2. Create a new Rancher cluster - ngrok

- Before creating the demo cluster, you need to provide the `NGROK_AUTHTOKEN` and `NGROK_API_KEY` that will be used to configure the endpoint.
- Run the script to create the base environment. Substitute `<rancher-hostname>` with the `ngrok` endpoint or spcify `$RANCHER_HOSTNAME` instead. This can be obtained from [ngrok dashboard](https://dashboard.ngrok.com/cloud-edge/endpoints).

```bash
./1-base-rancher-ngrok.sh <rancher-hostname-(optionally)>
```

3. Provision a cluster

```bash
export CLUSTER_NAME="aks-demo"
# export AZURE_SUBSCRIPTION_ID="subscription-id"
# export AZURE_CLIENT_SECRET="client-secret"
# export AZURE_CLIENT_ID="client-id"
# export AZURE_TENANT_ID="tenant-id"
export KUBERNETES_VERSION="v1.30.5"
export CONTROL_PLANE_MACHINE_COUNT=1
export WORKER_MACHINE_COUNT=1
export AZURE_INSTANCE=Standard_D2s_v3
export AZURE_LOCATION=southcentralus
```

Then, to apply the cluster template using `envsubst` and `kubectl`:
```bash
envsubst < azure-aks-cluster.yaml | kubectl apply -f -
```