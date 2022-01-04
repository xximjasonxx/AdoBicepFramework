targetScope = 'subscription'

var enableTypes = [
  'Microsoft.Storage/storageAccounts'
  'Microsoft.Web/sites'
]

module diagnosticSettings '../bicep-modules/diag-settings/deploy.bicep' = {
  name: 'diangosticDeploy'
  params: {
    enableDiagnosticsTypes: enableTypes
  }
}
