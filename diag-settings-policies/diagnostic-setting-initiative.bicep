
targetScope = 'subscription'

param configuration object
param logAnalyticsWorkspaceId string = ''

module diagPolicy 'diagnostic-setting-policy.bicep' = [for config in items(configuration): {
  name: '${config.key}Deployment'
  params: {
    resourceName: config.key
    resourceType: config.value.type
    logs: config.value.logs
    metrics: config.value.metrics
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
  }
}]

// create the policy set
resource diagnosticsInitiative 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: 'diagnosticsInitiative'
  properties: {
    description: 'An initiative to enable Azure Diagnostics'
    displayName: 'Azure Diagnostics Initiative'
    metadata: {
      category: 'Diagnostics'
    }
    policyDefinitions: [for (config, index) in items(configuration): {
      policyDefinitionId: diagPolicy[index].outputs.policyDefinitionId
    }]
  }
}

// outputs
output initiativeDefinitionId string = diagnosticsInitiative.id
