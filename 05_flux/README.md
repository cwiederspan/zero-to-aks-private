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
-var 'flux_repo=https://github.com/cwiederspan/zero-to-aks-flux.git'

# Apply the script with the specified variable values
terraform apply \
-var 'aks_rg=cdw-privateaks-cluster-20200406' \
-var 'aks_name=cdw-privateaks-cluster-20200406' \
-var 'flux_repo=https://github.com/cwiederspan/zero-to-aks-flux.git'

```
