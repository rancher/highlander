# Cluster Creation

## Purpose

Work through cluster creation from a clusterclass.

## Preparation

The steps from the quick start guide where followed and a sample definition was generated:

```bash
clusterctl generate cluster capi-quickstart --flavor development \
  --kubernetes-version v1.29.0 \
  --control-plane-machine-count=3 \
  --worker-machine-count=3 \
  > capi-quickstart.yaml
```

This was then edited to split out the ClusterClass into a separate file. And also multiple cluster definitions created using the class.

## Scenario 1

- Apply the class
- Apply the 2 cluster definitions

Look at what is created. This command can help:

```bash
clusterctl describe cluster cluster1
```

> Keep this management cluster and its child clusters and move on to the [single cluster operations](../2-single-cluster-operations/).
