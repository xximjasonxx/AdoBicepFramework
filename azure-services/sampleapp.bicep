
targetScope = 'resourceGroup'

// deploy vnet
resource ddos 'Microsoft.Network/ddosProtectionPlans@2021-03-01' = {
  name: 'ddos-m2gentest'
  location: 'eastus'
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-03-01' = {
  name: 'vnet-m2gentest'
  location: 'eastus'
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    ddosProtectionPlan: {
      id: ddos.id
    }
    subnets: [
      {
        name: 'storage'
        properties: {
          addressPrefix: '10.0.1.0/24'
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
          ]
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'apps'
        properties: {
          addressPrefix: '10.0.2.0/24'
          delegations: [
            {
              name: 'appservice-delegation'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
        }
      }
    ]
  }
}

// deploy storage account
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: 'stgm2gentestjm01'
  location: 'eastus'
  kind: 'BlobStorage'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    accessTier: 'Hot'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }
  }
}

module privateLink '../bicep-modules/private-link/private-link.bicep' = {
  name: 'blobPrivateLink'
  params: {
    blobStorageAccounts: [
      {
        name: storageAccount.name
        id: storageAccount.id
        subnetId: vnet.properties.subnets[0].id
      }
    ]
  }

  dependsOn: [
    vnet
    storageAccount
  ]
}

// deploy app service
resource plan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: 'plan-m2gentestjm01'
  location: 'eastus'
  sku: {
    tier: 'Standard'
    name: 'S1'
  }
  kind: 'app'
  properties: {
    reserved: true
  }
}

resource app 'Microsoft.Web/sites@2021-02-01' = {
  name: 'app-m2gentestjm01'
  location: 'eastus'

  properties: {
    serverFarmId: plan.id
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|5.0'
      vnetRouteAllEnabled: true
      alwaysOn: true
    }
    virtualNetworkSubnetId: vnet.properties.subnets[1].id
  }
}
