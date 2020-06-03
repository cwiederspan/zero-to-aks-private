# Dapr Demo

## Install Dapr

Based on steps found on [this page](https://github.com/dapr/docs/blob/master/getting-started/environment-setup.md).

```bash

helm repo add dapr https://daprio.azurecr.io/helm/v1/repo

helm repo update

kubectl create namespace dapr-system


# NOTE: This doesn't work (investigating)
#WORKAROUND: kubectl taint nodes akswin001000000 key=value:NoSchedule

helm install dapr dapr/dapr --namespace dapr-system --set nodeSelector="beta.kubernetes.io/os: linux"

# helm uninstall dapr --namespace dapr-system

kubectl get pods -n dapr-system

```

## Install Redis

```bash

helm repo add bitnami https://charts.bitnami.com/bitnami

kubectl create namespace dapr-demo

helm install redis bitnami/redis -n dapr-demo

kubectl get secret --namespace dapr-demo redis -o jsonpath="{.data.redis-password}" | base64 --decode

```

## Update the Components File

Set the redis password in the redis.yaml file.

```yaml

apiVersion: dapr.io/v1alpha1
kind: Component
metadata:
  name: statestore
spec:
  type: state.redis
  metadata:
  - name: "redisHost"
    value: "redis-master:6379"
  - name: "redisPassword"
    value: "<<PASSWORD_GOES_HERE>>"

```

## Install the Sample Application

```bash

kubectl apply -n dapr-demo -f ./redis.yaml
kubectl apply -n dapr-demo -f ./node-divider.yaml
kubectl apply -n dapr-demo -f ./python-multiplier.yaml
kubectl apply -n dapr-demo -f ./go-adder.yaml
kubectl apply -n dapr-demo -f ./dotnet-subtractor.yaml
kubectl apply -n dapr-demo -f ./react-calculator.yaml

```