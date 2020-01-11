#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# -e: immediately exit if any command has a non-zero exit status
# -o: prevents errors in a pipeline from being masked
# IFS new value is less likely to cause confusing bugs when looping arrays or arguments (e.g. $@)

function usage()
{
    echo "Usage: $0 args ..."
    echo "  -s, --dev-signature         <string> [required]"
    echo "  -h, --help                  <flag>   [optional]"
    echo "  e.g.: $ $0 -s bobby"
    exit 1
}

# set help flag
declare help=0

# declare required params
declare devSignature=""

# decalre optional params
declare location="australiasoutheast"

# parse arguments
# https://gist.github.com/hfossli/4368aa5a577742c3c9f9266ed214aa58
# https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
# best answer by Inanc Gumus edited by Michael
while [[ "$#" > 0 ]]; do case $1 in
    -s|--dev-signature) devSignature="$2"; shift;;
    -h|--help) help=1;;
    *) echo "Unknown parameter passed: $1\n"; usage;;
esac; shift; done

# check for -h, --help flag and exit if present
if [ "$help" == 1 ]; then usage; fi;

# check required arguments
if [ "$devSignature" == "" ]; then
    echo "-s, --dev-signature is not set"
    echo ""
    usage
fi;

# configure default location as a safe guard
az configure --defaults location=$location

rg="dev-rg-$devSignature"
echo "creating resource group $rg"
az group create \
    --name $rg \
    --location $location

appinsName="dev-appins-$devSignature"
echo "creating application insights $appinsName"
# optional: may have to run the az extension command once
az extension add -n application-insights
az monitor app-insights component create \
    --app $appinsName \
    --resource-group $rg \
    --location $location

kv="kv"
dev="dev"
vaultName="$dev$kv$devSignature"
kvExists=$(az keyvault list -g $rg --query "[?name=='$vaultName'].[name]" -o tsv)
if [[ -z $kvExists ]]; then
    echo "creating azure keyvault $vaultName"
    az keyvault create \
        --name $vaultName \
        --resource-group $rg \
        --sku standard \
        --location $location
else
    echo "KeyVault '$vaultName' already exists"
fi

sbusNamespace="dev-sbus-$devSignature"
echo "creating azure service bus $sbusNamespace"
# todo: set tags
az servicebus namespace create \
    --name $sbusNamespace \
    --resource-group $rg \
    --location $location \
    --sku standard

queueName="default"
echo "creating $queueName"
az servicebus queue create \
    --resource-group $rg \
    --namespace-name $sbusNamespace \
    --name $queueName \
    --max-size 1024

dev="dev"
st="st"
storageName="$dev$st$devSignature"
echo "creating storage for general purpose $storageName"
az storage account create \
    --name $storageName \
    --resource-group $rg \
    --location $location \
    --sku Standard_LRS \
    --kind StorageV2
connectionString=$(az storage account show-connection-string --name $storageName -o tsv)
echo "creating container $storageName -- default"
az storage container create \
    --name default \
    --connection-string $connectionString
