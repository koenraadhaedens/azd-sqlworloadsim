param sqlAdminUsername string
@secure()
param sqlAdminPassword string
param location string = resourceGroup().location

resource sqlVm 'Microsoft.Compute/virtualMachines@2021-07-01' = {
  name: 'sqlVm'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_DS1_v2'
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftSQLServer'
        offer: 'SQL2019-WS2019'
        sku: 'Web'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    osProfile: {
      computerName: 'sqlVm'
      adminUsername: sqlAdminUsername
      adminPassword: sqlAdminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: '<nicId>' // Replace with actual NIC resource ID
        }
      ]
    }
  }
}

resource customScriptExtension 'Microsoft.Compute/virtualMachines/extensions@2021-07-01' = {
  parent: sqlVm
  name: 'uploadAndImportBacpac'
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        'https://raw.githubusercontent.com/koenraadhaedens/azd-sqlworloadsim/refs/heads/main/infra/uploadAndImportBacpac.ps1'
      ]
      commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File uploadAndImportBacpac.ps1'
    }
  }
}
