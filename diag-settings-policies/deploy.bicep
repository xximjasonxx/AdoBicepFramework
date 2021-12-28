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
    logAnalyticsWorkspaceId: '/subscriptions/cd35503e-9e28-4b2b-8445-45fc816ba088/resourcegroups/rg-sandbox/providers/microsoft.operationalinsights/workspaces/law-testappjx01'
  }
}
