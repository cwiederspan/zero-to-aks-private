# Setup Ingress

## Setting Up

```bash

# Use remote storage
terraform init \
--backend-config ../../../config/backend-secrets.tfvars \
--backend-config "key=ingress-nginx-sample.tfstate"

```

## Execution

```bash

# Run the plan to see the changes
terraform plan \
-var 'namespace=ingress-nginx-demo' \
-var 'aks_rg=cdw-privateaks-cluster-20200406' \
-var 'aks_name=cdw-privateaks-cluster-20200406'

# Apply the script with the specified variable values
terraform apply \
-var 'namespace=ingress-nginx-demo' \
-var 'aks_rg=cdw-privateaks-cluster-20200406' \
-var 'aks_name=cdw-privateaks-cluster-20200406'

```
