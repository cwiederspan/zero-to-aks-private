# Initial Unmanaged Resources


## Setting Up

```bash

# No remote storage here
terraform init

# Apply the script with the specified variable values
terraform apply \
-var 'resource_group_name=cdw-privateaks-state-20200406' \
-var 'storage_account_name=tfstate20200406' \
-var 'blob_container_name=tfstatefiles' \
-var 'location=westus2'

```

## Execution