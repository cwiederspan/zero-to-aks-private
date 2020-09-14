```bash

kubectl create ns apim-testing

kubectl create secret generic cdw-privateaks-cluster-20200406-token -n apim-testing --from-literal=value="GatewayKey <<TOKEN_GOES_HERE>>" --type=Opaque

kubectl apply -f cdw-privateaks-cluster-20200406.yaml

kubectl run -i --tty busybox --image=busybox --restart=Never -n apim-testing

>> wget -qO- http://40.64.89.175/echo/test2

```
