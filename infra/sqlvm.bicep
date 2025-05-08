param location string = resourceGroup().location
param vmName string
param adminUsername string
@secure()
param adminPassword string
param bacpacStorageUrl string
param targetSqlServer string
param targetDb string
param sqlAdmin string
@secure()
param sqlPassword string

resource sqlVm 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_DS2_v2'
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftSQLServer'
        offer: 'SQL2019-WS2022'
        sku: 'Enterprise'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    networkProfile: {
      networkInterfaces: []
    }
  }
}

resource scriptExt 'Microsoft.Compute/virtualMachines/extensions@2023-03-01' = {
  parent: sqlVm
  name: 'customScriptExtension'
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        'https://<yourstorageaccount>.blob.core.windows.net/scripts/deploy-bacpac.ps1'
      ]
    }
    protectedSettings: {  commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File deploy-bacpac.ps1 -BacpacUrl "${bacpacStorageUrl}" -SqlServer "${targetSqlServer}" -Database "${targetDb}" -SqlAdmin "${sqlAdmin}" -SqlPassword "${sqlPassword}"'

    }
    
  }
}
