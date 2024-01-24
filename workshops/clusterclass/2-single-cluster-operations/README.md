# Individual Cluster Operations

## Purpose

Work through operations against a single cluster that was created from a class.

Some things to consider:

- Editing experience for a clusterclass created cluster (i.e. topology based) vs non-clusterclass created
- Should we allow editing of the rendered templates
- Visualizing clusterclass and its created clusters

## Scenario 1 - upgrade k8s version

- Apply class
- Apply cluster definitions
- Wait for clusters to be provisioned
- Edit cluster1 definition and change version to v1.29.0

**TODO: observe & capture what happens

## Scenario 2 - scale machine deployment

- Edit cluster1 definition
- Change spec.topology.workers.machinedeployments[0].replicas to 2. Or run

```bash
kubectl  patch cluster cluster2 --type json --patch '[{"op": "replace", "path": "/spec/topology/workers/machineDeployments/0/replicas",  "value": 1}]'
```

**TODO: observe & capture what happens

## Scenario 3 - add a machine deployment

- Edit cluster1 definition
- Add a new machine deployment

**TODO: observe & capture what happens

## Scenario 4 - remove a machine deployment

- Edit cluster1 definition
- Remove one of the machinedeployment entries

**TODO: observe & capture what happens

## Scenario 5 - scale control plane

- edit cluster1 definition
- Change spec.topology.controlPlane.replicas to 3

**TODO: observe & capture what happens

## Scenario 6 - change variable value

- edit cluster1 definitiom
- Change the value of the **etcdImageTag** variable to `3.5.9-0`

**TODO: observe & capture what happens

## Scenario 7 - change non-cluster resource

- Edit the machine deployment for cluster 1
- Change the replicas to 3

> The same applies to the other resource types like DockerCluster etc

**TODO: observe & capture what happens
