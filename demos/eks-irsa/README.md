# Rancher Turtles & EKS IRSA Demo

## Setup Before Demo

### Setup Rancher

1. Create EKS cluster for rancher

```bash
eksctl create cluster --name rancher-demo --version 1.26 --nodegroup-name ranchernodes --nodes 2 --nodes-min 1 --nodes-max 2 --managed --region eu-west-2

eksctl utils associate-iam-oidc-provider --cluster rancher-demo --approve
```

2. Install ngix helm ingress

```bash
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --set controller.service.type=LoadBalancer \
  --version 4.9.0 \
  --create-namespace
```

3. Get the external address of the EKS ingress (for use later):

```bash
kubectl get service ingress-nginx-controller --namespace=ingress-nginx
```

4. Install cert-manager

```bash
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.5.1/cert-manager.crds.yaml

helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.5.1
```

5. Install Rancher

```bash
kubectl create namespace cattle-system

helm install rancher --devel rancher-latest/rancher \
  --namespace cattle-system \
  --set bootstrapPassword=admin \
  --set replicas=1 \
  --set hostname=<ingress address> \
  --set global.cattle.psp.enabled=false \
  --version v2.8.0 \
  --set ingress.ingressClassName=nginx
```

6. Login into Rancher using admin password:

```
https://<ingress address>
```
### Update IAM Role

1. Go to AWS console
2. Get the OIDC provider for the EKS cluster
3. Go to IAM
4. Edit the trust policy of the ****controllers.cluster-api-provider-aws.sigs.k8s.io** role

```jsono
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${AWS_ACCOUNT_ID}:oidc-provider/oidc.eks.${AWS_REGION}.amazonaws.com/id/${OIDC_PROVIDER_ID}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "ForAnyValue:StringEquals": {
          "oidc.eks.${AWS_REGION}.amazonaws.com/id/${OIDC_PROVIDER_ID}:sub": [
            "system:serviceaccount:capa-system:capa-controller-manager",
            "system:serviceaccount:capi-system:capi-controller-manager",
            "system:serviceaccount:capa-eks-control-plane-system:capa-eks-control-plane-controller-manager",
            "system:serviceaccount:capa-eks-bootstrap-system:capa-eks-bootstrap-controller-manager",
          ]
        }
      }
    }
  ]
}
```

5. Save the ARN of the role

### Disable embedded CAPI

1. Bounce the fleet controller
2. Disbale embedded CAPI feature:

```bash
kubectl apply -f feature.yaml
```

3. Wait for Rancher to restart and embedded capi pod to be stopped
4. Cleanup old webhooks

```bash
kubectl delete mutatingwebhookconfigurations.admissionregistration.k8s.io mutating-webhook-configuration

kubectl delete validatingwebhookconfigurations.admissionregistration.k8s.io validating-webhook-configuration
```

## Demo

### Install Rancher Turtles

- Explore the local cluster
- Go to App-> Repositories
- Click **Create** to add a new repository Name: turtles Index URL: `https://rancher-sandbox.github.io/rancher-turtles`
- Go to Apps->Charts
- Filter for Turtles
- Click **rancher-turtles**
- Click **Install**
  - On **Namespace** select **Create a new namespace**
  - Enter **rancher-turtles-system** as the namespace
  - Enter **rancher-turtles** as the **Name**
- Click **Next**
- In **Edit YAML** change:
  - **cert-manager.Enabled** to **false**
- Click **Install**
- In terminal watch Rancher Turtles & CAPI Operator get deployed
- Wait for the capi-controller-manager and kubeadm controllers to be deployed
- Edit the Rancher Turtles deployment and set insecure `--insecure-skip-verify=true`

### Enable the CAPA provider

1. Create namespace

```bash
kubectl create namespace capa-system
```

2. Create the variables. Ensure you replace **<ARN_OF_ROLE>** with the ARN of the role from before

```bash
kubectl create secret generic capa-variables -n capa-system --from-literal=AWS_CONTROLLER_IAM_ROLE=<ARN_OF_ROLE> --from-literal=AWS_B64ENCODED_CREDENTIALS=Cg== --from-literal=CLUSTER_TOPOLOGY=true --from-literal=EXP_CLUSTER_RESOURCE_SET=true --from-literal=EXP_MACHINE_POOL=true
```

> You can look at [capa-variables.yaml](capa-variables.yaml) to see what the secret looks like if needed

3. Install the provider

```bash
kubectl apply -f capa-provider.yaml
```

### Create a cluster

- Go back to Rancher Manager
- Use menu to go to **Continuos Delivery**
- Change namespace to **fleet-local**
- Go to **Git Repos**
- Click **Add Repository**
- Fill in:
    Name: clusters
    Repository URL: get HTTPS clone url from samples reposiroty (<https://github.com/rancher-sandbox/rancher-turtles-fleet-example>)
    Branch Name: aws
- Click **Next**
- Click **Create**
- Watch the resources become ready

### Import into Rancher

> This is normally a one time task.

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
