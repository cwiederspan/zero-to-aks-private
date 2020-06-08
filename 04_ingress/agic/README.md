# Setup Ingress

## Setting Up

```bash

# Use remote storage
terraform init \
--backend-config ../../config/backend-secrets.tfvars \
--backend-config "key=ingress-agic.tfstate"

```

## Execution

```bash

# Run the plan to see the changes
terraform plan \
-var 'base_name=cdw-privateaks-cluster-20200406' \
-var 'aks_rg=cdw-privateaks-cluster-20200406' \
-var 'aks_name=cdw-privateaks-cluster-20200406' \
-var 'vnet_rg=cdw-privateaks-network-20200406' \
-var 'vnet_name=cdw-mynetwork-20200406' \
-var 'ingress_subnet_name=ingress-subnet' \
-var 'cluster_subnet_name=cluster-subnet' \
-var 'ingress_namespace=ingress-agic'

# Apply the script with the specified variable values
terraform apply \
-var 'base_name=cdw-privateaks-cluster-20200406' \
-var 'aks_rg=cdw-privateaks-cluster-20200406' \
-var 'aks_name=cdw-privateaks-cluster-20200406' \
-var 'vnet_rg=cdw-privateaks-network-20200406' \
-var 'vnet_name=cdw-mynetwork-20200406' \
-var 'ingress_subnet_name=ingress-subnet' \
-var 'cluster_subnet_name=cluster-subnet' \
-var 'ingress_namespace=ingress-agic'

```
