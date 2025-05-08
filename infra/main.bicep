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


module sqlServerModule './sqlserver.bicep' = {
  name: 'deploySqlServer'
  params: {
    sqlServerName: 'your-sqlserver'
    adminLogin: 'sqladminuser'
    adminPassword: winVMPassword
  }
  scope: rg
}

module vmModule './sqlvm.bicep' = {
  name: 'deploySqlVM'
  params: {
    vmName: 'sqlimportvm'
    adminUsername: 'vmadmin'
    adminPassword: 'your-vm-password'
    bacpacStorageUrl: 'https://github.com/koenraadhaedens/azd-sqlworloadsim/raw/refs/heads/main/media/adventureworks2017.bacpac'
    targetSqlServer: sqlServerModule.outputs.sqlServerFqdn
    targetDb: 'AdventureWorks2017'
    sqlAdmin: 'sqladminuser'
    sqlPassword: winVMPassword
  }
  dependsOn: [
    sqlServerModule
  ]
  scope: rg
}
