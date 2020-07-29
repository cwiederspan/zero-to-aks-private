# Setup Cluster

## Setting Up

```bash

# Use remote storage
terraform init \
--backend-config ../config/backend-secrets.tfvars \
--backend-config "key=cluster.tfstate"

```

## Execution

```bash

# Run the plan to see the changes
terraform plan \
-var 'name_prefix=cdw' \
-var 'name_base=privateaks-cluster' \
-var 'name_suffix=20200406' \
-var 'location=westus2' \
-var 'enable_azure_policy=true' \
-var 'vnet_rg_name=cdw-privateaks-network-20200406' \
-var 'vnet_name=cdw-mynetwork-20200406' \
-var 'cluster_subnet_name=cluster-subnet' \
-var 'acr_rg_name=cdw-shared-resources' \
-var 'acr_name=cdwms' \
-var 'node_count=2' \
--var-file=secrets.tfvars

# Apply the script with the specified variable values
terraform apply \
-var 'name_prefix=cdw' \
-var 'name_base=privateaks-cluster' \
-var 'name_suffix=20200406' \
-var 'location=westus2' \
-var 'enable_azure_policy=true' \
-var 'vnet_rg_name=cdw-privateaks-network-20200406' \
-var 'vnet_name=cdw-mynetwork-20200406' \
-var 'cluster_subnet_name=cluster-subnet' \
-var 'acr_rg_name=cdw-shared-resources' \
-var 'acr_name=cdwms' \
-var 'node_count=2' \
--var-file=secrets.tfvars

```
