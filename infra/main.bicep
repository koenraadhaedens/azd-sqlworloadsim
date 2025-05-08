targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

@secure()
@description('Password for the Windows VM')
param winVMPassword string //no value specified, so user will get prompted for it during deployment

var tags = {
  'azd-env-name': environmentName
}

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${environmentName}'
  location: location
  tags: tags
}

param storageAccountName string = 'mystorageaccount'
param sqlAdminUsername string = 'sqladmin'
param sqlDatabaseName string = 'adventureworks2017'


module storageModule './modules/storage.bicep' = {
  name: 'storageDeployment'
  params: {
    storageAccountName: storageAccountName
    location: location
  }
  scope: rg
}

module sqlVmModule './modules/sqlvm.bicep' = {
  name: 'sqlVmDeployment'
  dependsOn: [
    storageModule
  ]
  params: {
    sqlAdminUsername: sqlAdminUsername
    sqlAdminPassword: winVMPassword
    location: location
    
  }
  scope: rg
}

module sqlDbModule './modules/sqlDatabase.bicep' = {
  name: 'sqlDatabaseDeployment'
  dependsOn: [
    storageModule
    sqlVmModule
  ]
  params: {
    sqlServerName: 'my-sql-server'
    sqlAdminUsername: sqlAdminUsername
    sqlAdminPassword: winVMPassword
    sqlDatabaseName: sqlDatabaseName
    location: location
  }
  scope: rg
}
