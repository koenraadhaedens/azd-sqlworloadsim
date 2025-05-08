param location string = resourceGroup().location
param sqlServerName string
param adminLogin string
@secure()
param adminPassword string

resource sqlServer 'Microsoft.Sql/servers@2022-02-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: adminLogin
    administratorLoginPassword: adminPassword
    version: '12.0'
  }
}


output sqlServerFqdn string = sqlServer.properties.fullyQualifiedDomainName
