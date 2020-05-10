# Consul Demo

## Scale the Cluster (If Necessary)

```bash

az aks nodepool scale \
    -g cdw-privateaks-cluster-20200406 \
    --cluster-name cdw-privateaks-cluster-20200406 \
    --name lnx000 \
    --node-count 3 \
    --no-wait

```

## Install Consul

```bash

helm repo add hashicorp https://helm.releases.hashicorp.com

helm install consul hashicorp/consul --set global.name=consul

kubectl create namespace consul

helm install consul hashicorp/consul \
  --namespace consul \
  --set global.name=consul \
  --set client.enabled=true \
  --set client.grpc=true \
  --set connectInject.enabled=true \
  --set connectInject.nodeSelector="beta.kubernetes.io/os: linux" \
  --set client.nodeSelector="beta.kubernetes.io/os: linux" \
  --set server.nodeSelector="beta.kubernetes.io/os: linux" \
  --set syncCatalog.nodeSelector="beta.kubernetes.io/os: linux" \
  --set syncCatalog.enabled=true

```

## Install the Sample App

```bash

kubectl create namespace consul-demo

kubectl apply -n consul-demo -f demo-app.yaml

```
