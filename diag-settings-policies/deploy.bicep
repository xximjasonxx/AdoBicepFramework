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
  appService: {
    type: 'Microsoft.Web/sites'
    matchType: ''
    nameExtra: ''
    logs: [
      'AppServiceHTTPLogs'
      'AppServiceConsoleLogs'
      'AppServiceAppLogs'
      'AppServiceAuditLogs'
      'AppServiceIPSecAuditLogs'
      'AppServicePlatformLogs'
    ]
    metrics: [
      'AllMetrics'
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

// create the assignment
resource policyAssignment 'Microsoft.Authorization/policyAssignments@2021-06-01' = {
  name: 'assignDiagnosticsSettingsInitiative'
  location: 'eastus'
  properties: {
    policyDefinitionId: initiative.outputs.initiativeDefinitionId
    displayName: 'AssignDiagnosticsSettingsInitiative'
  }
  identity: {
    type: 'SystemAssigned'
  }
}
