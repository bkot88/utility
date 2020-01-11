# Azure CLI related scripts
A collection of helpful azure-cli related scripts.

### Prerequisite
* Azure CLI [Install Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)

Verify the installation:
```bash
> az --version
```
Login:
```bash
> az login
```
Or set subscription:
```bash
> az account list
> az account set -s <subscription>
```

### Scripts

#### [Developer Azure Resources](https://github.com/bkot88/utility/blob/master/scripts/azure-cli/developer-azure-resources.sh)
The script provisions some basic azure resources useful for development, i.e., a resource group, storage, service bus, key vault... to name a few.
Note: A basic naming convention is used to name resources.

Usage:
As executable:
```bash
> chmod +x developer-azure-resources.sh
> ./developer-azure-resources.sh --dev-signature <my-signiture>
```
Or:
```bash
> sh developer-azure-resources.sh --dev-signature <my-signiture>
```
