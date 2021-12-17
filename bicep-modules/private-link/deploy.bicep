
param blobStorageAccounts array = []

resource blobPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = if (length(blobStorageAccounts) > 0) {
  name: 'privatelink.blob.${environment().suffixes.storage}'
  location: 'global'
  properties: {
  }
}

module blobSAs './blob-private-link.bicep' = [for account in blobStorageAccounts: {
  name: 'deploypl-${account.name}'
  params: {
    storageAccountName: account.name
    storageAccountId: account.id
    subnetId: account.subnetId
    privateDnsZoneId: blobPrivateDnsZone.id
  }

  dependsOn: [
    blobPrivateDnsZone
  ]
}]
