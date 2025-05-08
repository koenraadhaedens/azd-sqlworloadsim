param sqlServerName string = 'my-sql-server'
param sqlAdminUsername string = 'sqladmin'
@secure()
param sqlAdminPassword string
param sqlDatabaseName string = 'mydatabase'
param location string = resourceGroup().location

module sqlDbModule './modules/sqlDatabase.bicep' = {
  name: 'sqlDatabaseDeployment'
  params: {
    sqlServerName: sqlServerName
    sqlAdminUsername: sqlAdminUsername
    sqlAdminPassword: sqlAdminPassword
    sqlDatabaseName: sqlDatabaseName
    location: location
  }
}

