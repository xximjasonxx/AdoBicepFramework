targetScope = 'subscription'

var enableTypes = [
  'Microsoft.Storage/storageAccounts'
  'Microsoft.Web/sites'
]

module diagnosticSettings '../bicep-modules/diag-settings/deploy.bicep' = {
  name: 'diangosticDeploy'
  params: {
    enableDiagnosticsTypes: enableTypes
    userIdentityResourceId: '/subscriptions/cd35503e-9e28-4b2b-8445-45fc816ba088/resourceGroups/rg-sandbox/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-initiativeManagedIdentity'
  }
}
