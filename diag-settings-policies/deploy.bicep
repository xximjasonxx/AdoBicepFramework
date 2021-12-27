targetScope = 'subscription'

var configs = {
  storageAccount: {
    type: 'Microsoft.Storage/storageAccounts'
    logs: [
      'StorageRead'
      'StorageWrite'
      'StorageDelete'
    ]
    metrics: [
      'Transaction'
    ]
  }
}

module initiative 'diagnostic-setting-initiative.bicep' = {
  name: 'diagnosticsSettingsInitiative'
  params: {
    configuration: configs
  }
}
