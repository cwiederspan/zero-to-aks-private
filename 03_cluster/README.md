# Setup Cluster

## Setting Up

```bash

# Use remote storage
terraform init --backend-config backend-secrets.tfvars

```

## Execution

```bash

# Apply the script with the specified variable values
terraform apply \
-var 'name_prefix=cdw' \
-var 'name_base=privateaks-cluster' \
-var 'name_suffix=20200406' \
-var 'aks_version=1.16.7' \
-var 'location=westus2' \
-var 'vnet_rg_name=cdw-privateaks-network-20200406' \
-var 'vnet_name=cdw-mynetwork-20200406' \
-var 'cluster_subnet_name=cluster-subnet' \
--var-file=secrets.tfvars
