param storageAccountName string = 'mystorageaccount'
param sqlAdminUsername string = 'sqladmin'
@secure()
param sqlAdminPassword string
param sqlDatabaseName string = 'mydatabase'
param location string = resourceGroup().location

module storageModule './modules/storage.bicep' = {
  name: 'storageDeployment'
  params: {
    storageAccountName: storageAccountName
    location: location
  }
}

module sqlVmModule './modules/sqlvm.bicep' = {
  name: 'sqlVmDeployment'
  params: {
    sqlAdminUsername: sqlAdminUsername
    sqlAdminPassword: sqlAdminPassword
    location: location
  }
}

module sqlDbModule './modules/sqlDatabase.bicep' = {
  name: 'sqlDatabaseDeployment'
  params: {
    sqlServerName: 'my-sql-server'
    sqlAdminUsername: sqlAdminUsername
    sqlAdminPassword: sqlAdminPassword
    sqlDatabaseName: sqlDatabaseName
    location: location
  }
}
