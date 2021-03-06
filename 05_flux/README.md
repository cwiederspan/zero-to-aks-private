# Setup Flux

## Setting Up

```bash

# Use remote storage
terraform init \
--backend-config ../config/backend-secrets.tfvars \
--backend-config "key=flux.tfstate"

```

## Execution

```bash

# Run the plan to see the changes
terraform plan \
-var 'aks_rg=cdw-privateaks-cluster-20200406' \
-var 'aks_name=cdw-privateaks-cluster-20200406' \
-var 'flux_repo=git@github.com:cwiederspan/aks-flux-cluster01' \
-var 'flux_path=production' \
-var 'flux_poll_interval=2m'


# Apply the script with the specified variable values
terraform apply \
-var 'aks_rg=cdw-privateaks-cluster-20200406' \
-var 'aks_name=cdw-privateaks-cluster-20200406' \
-var 'flux_repo=git@github.com:cwiederspan/aks-flux-cluster01' \
-var 'flux_path=production' \
-var 'flux_poll_interval=2m'

# Get the Flux User credentials
fluxctl identity --k8s-fwd-ns=flux

# You can get the private key back out of the Kubernetes Secret
# kubectl get secret flux-git-deploy -n flux -o jsonpath="{.data.identity}" | base64 --decode

# Create a Deployment Key in GitHub with the above value

```
