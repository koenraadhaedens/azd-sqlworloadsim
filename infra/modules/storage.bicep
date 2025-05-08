param storageAccountName string
param location string = resourceGroup().location
@description('Used to force the deployment script to run on every deployment')
param forceUpdateTag string = utcNow()

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = {
  name: '${storageAccount.name}/default/tempbacpac'
  properties: {
    publicAccess: 'None'
  }
}

resource generateSasScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'generateSasToken'
  location: location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.30.0'
    timeout: 'PT10M'
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
    scriptContent: '''
      sas=$(az storage blob generate-sas \
        --account-name ${storageAccountName} \
        --container-name tempbacpac \
        --name adventureworks.bacpac \
        --permissions r \
        --expiry $(date -u -d "1 day" '+%Y-%m-%dT%H:%MZ') \
        --output tsv)

      echo "sasToken=$sas" >> $AZ_SCRIPTS_OUTPUT_PATH
    '''
    forceUpdateTag: forceUpdateTag
    storageAccountSettings: {
      storageAccountName: storageAccount.name
    }
  }
}


output sasToken string = generateSasScript.properties.outputs.sasToken
output storageAccountName string = storageAccount.name
