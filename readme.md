# Traefikee-operator

Traefikee-operator is a Kubernetes operator to deploy and manage Traefik Enterprise Edition resources for a Kubernetes cluster.

## Installation

The operator installs the v1.2.1 version of TraefikEE, and can run on Minikube v0.33.1+, Kubernetes 1.10.0+ and OpenShift 4.2+

### Manual

Clone the repo and create a `traefikee` namespace:

```
git clone https://github.com/containous/traefikee-operator.git
traefikee-operator/
```

Then, from this repository root directory, create the specific CRDs and resources needed for Traefikee-Operator:

```
kubectl create namespace traefikee
kubectl create -n traefikee secret generic license --from-literal=license=${TRAEFIKEE_LICENSE_KEY}
kubectl apply -f deploy/crds/containo.us_traefikees_crd.yaml
kubectl apply -f deploy/service_account.yaml
kubectl apply -f deploy/role.yaml
kubectl apply -f deploy/role_binding.yaml
oc apply -f deploy/traefikee-scc.yaml
oc adm policy add-scc-to-user traefikee-scc -z default -n traefikee
```

Install the operator:

```
sed 's|{{REPLACE_IMAGE}}|containous/traefikee-operator:latest|g' deploy/operator.yaml | kubectl apply -f -
```

**IMPORTANT**: Ensure that your cluster is able to pull the image pushed to your registry.


Create a Traefikee CRD for the installation

```bash
echo "apiVersion: containo.us/v1alpha1
kind: Traefikee
metadata:
  name: traefikee-setup
  namespace: traefikee
spec:
  image: store/containous/traefikee:v1.3.0
  clustername: traefikee
  controllers: 1
  proxies: 2" | kubectl apply -f -
```

### Connect to the cluster with traefikeectl

```
traefikeectl connect --kubernetes

traefikeectl deploy --clustername=traefikee \
    --defaultentrypoints=http,https \
    --entryPoints='Name:http Address::80' \
    --entryPoints='Name:https Address::443 TLS' \
    --logLevel=INFO \
    --kubernetes
```

## Cleanup

Delete the operator and its related resources:

```
kubectl delete -f deploy/crds/containo.us_traefikees_crd.yaml
kubectl delete -f deploy/service_account.yaml
kubectl delete -f deploy/role.yaml
kubectl delete -f deploy/role_binding.yaml
kubectl delete -f deploy/operator.yaml
````
