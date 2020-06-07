# Setup Shared Resources


## Setting Up

```bash

# Use remote storage
terraform init \
--backend-config ../config/backend-secrets.tfvars \
--backend-config "key=networking.tfstate"

```

## Execution

```bash

# Apply the script with the specified variable values
terraform apply \
-var 'resource_group_name=cdw-privateaks-network-20200406' \
-var 'vnet_name=cdw-mynetwork-20200406' \
-var 'location=westus2'

```
