# Class Level Cluster Operations

## Purpose

Work through operations against a clusterclass that effect multiple clusters.

Some things to consider:

- UI experience for performing clusterclass operations
    - copy class & templates in one operation?
- Visualizing clusterclass and its created clusters

## Setup

- Create a new management cluster using the script in the root directory.
- apply class1
- apply cluster1 & cluster2

## Scenario 1 - edit template

- Look at class 1
- Edit the dockermachine template for the controlplane

```bash
kubectl edit dockermachinetemplate quick-start-v1-control-plane
```

- Add annotation to the spec

**TODO: observe & capture what happens

## Scenario 2 - switch template in class

- Look at class1
- Look at **class1-md-template-2.yaml**
- Edit **quick-start-v1** clusterclass
- change **workers.machinedeployments[0].infrastructureRef.name** to **quick-start-v1-default-worker-machinetemplate2**

**TODO: observe & capture what happens

## Scenario 3 - update clusterclass (variable)

- Edit the **quick-start-v1**
- Change the default value of the **etcdImageTag** variable to `3.5.9-0`

**TODO: observe & capture what happens

## Scenario 4 - update clusterclass (workers)

- Edit the **quick-start-v1**
- Change **workers.machinedeployments[0].template** to add metadata/annotations

**TODO: observe & capture what happens

> Delete cluster1 & cluster 2

## Scenario 5 - rebase

- Apply cluster3 & cluster4
- Apply class2
- Edit cluster3 and change the class to v2

**TODO: observe & capture what happens

> Delete cluster1 & cluster 2
