targetScope = 'subscription'
var contributorRoleDefId = 'b24988ac-6180-42a0-ab88-20f7382dd24c'

@minLength(1)
param enableDiagnosticsTypes array

// define a mapping for our values
var diagnosticSettingsMapping = {
  'Microsoft.Storage/storageAccounts': {
    logs: [
      'StorageRead'
      'StorageWrite'
      'StorageDelete'
    ]
    metrics: [
      'Transaction'
    ]
  }
  'Microsoft.Web/sites': {
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

var configuration = [for type in enableDiagnosticsTypes: {
  name: split(type, '/')[1]
  type: type
  logs: diagnosticSettingsMapping[type].logs
  metrics: diagnosticSettingsMapping[type].metrics
}]

module initiative 'diagnostic-setting-initiative.bicep' = {
  name: 'diagnosticsSettingsInitiative'
  params: {
    configuration: configuration
    logAnalyticsWorkspaceId: '/subscriptions/cd35503e-9e28-4b2b-8445-45fc816ba088/resourcegroups/rg-sandbox/providers/microsoft.operationalinsights/workspaces/law-testappjx01'
  }
}

// create the assignment
module initiativeAssignment 'intiative-assignment.bicep' = {
  name: 'initiatveAssignmentDeployment'
  params: {
    intiativeDefinitionId: initiative.outputs.initiativeDefinitionId
  }
}

// for the identity created - give it the contributor role
module initiativeRoleAssignment 'initiative-role-assignment.bicep' = {
  name: 'initiativeRoleAssignmentDeployment'
  params: {
    roleDefinitionId: contributorRoleDefId
    initiativeIdentityPrincipalId: initiativeAssignment.outputs.initiativeAssignmentPrincipalId
  }

  dependsOn: [
    initiativeAssignment
  ]
}
