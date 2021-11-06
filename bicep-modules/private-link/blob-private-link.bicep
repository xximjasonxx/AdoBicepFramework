
param storageAccountName string
param storageAccountId string
param subnetId string
param privateDnsZoneId string

// private endpoint
resource storagePrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-03-01' = {
  name: storageAccountName
  location: 'eastus'

  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'pse-${storageAccountName}'
        properties: {
          privateLinkServiceId: storageAccountId
          groupIds: [
            'Blob'
          ]
        }
      }
    ]
  }
}

// dns zone group
var blobPrivateDnsZoneGroup = '${storageAccountName}/blob'
resource dnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-03-01' = {
  name: blobPrivateDnsZoneGroup
  dependsOn: [
    storagePrivateEndpoint
  ]

  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'blobDnsConfigs'
        properties: {
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
}
