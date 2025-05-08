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
  name: '${sqlServer.name}/${sqlDatabaseName}'
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 2147483648
  }
}

resource importScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'importBacpacScript'
  location: location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.30.0'
    timeout: 'PT30M'
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
    scriptContent: '''
      az sql db import \
        --admin-user ${sqlAdminUsername} \
        --admin-password ${sqlAdminPassword} \
        --name ${sqlDatabaseName} \
        --server ${sqlServerName} \
        --storage-key-type SharedAccessKey \
        --storage-key "<sasToken>" \
        --storage-uri "https://<storageAccountName>.blob.core.windows.net/tempbacpac/adventureworks.bacpac" \
        --resource-group ${resourceGroup}
    '''
    environmentVariables: []
  }
}
