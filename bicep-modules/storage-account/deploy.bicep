
@minLength(5)
@maxLength(16)
param account_name string

@allowed([
  'East US'
  'eastus'
])
param account_location string

resource storage 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: account_name
  kind: 'StorageV2'
  location: account_location
  sku: {
    name: 'Standard_LRS'
  }
}
