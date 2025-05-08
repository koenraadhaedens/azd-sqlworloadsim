param sqlServerName string
param sqlAdminUsername string
@secure()
param sqlAdminPassword string
param sqlDatabaseName string
param location string = resourceGroup().location

resource sqlServer 'Microsoft.Sql/servers@2022-02-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlAdminUsername
    administratorLoginPassword: sqlAdminPassword
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2022-02-01-preview' = {
  parent: sqlServer
  name: sqlDatabaseName
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 2147483648
  }
  location: location
}

resource importScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'importFromGitHubScript'
  location: location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.30.0'
    timeout: 'PT30M'
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
    scriptContent: '''
      curl -L -o adventureworks.bacpac "https://raw.githubusercontent.com/<username>/<repo>/<branch>/path/to/adventureworks.bacpac"

      az storage blob upload \
        --account-name $storageAccount \
        --container-name $container \
        --name adventureworks.bacpac \
        --file adventureworks.bacpac \
        --auth-mode key

      az sql db import \
        --admin-user $sqlAdminUsername \
        --admin-password $sqlAdminPassword \
        --name $sqlDatabaseName \
        --server $sqlServerName \
        --storage-key-type StorageAccessKey \
        --storage-key $storageKey \
        --storage-uri "https://$storageAccount.blob.core.windows.net/$container/adventureworks.bacpac" \
        --resource-group $resourceGroup
    '''
    environmentVariables: [
      // Add all required variables here
    ]
  }
}
