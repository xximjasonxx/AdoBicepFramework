
targetScope = 'subscription'

param configuration array
param logAnalyticsWorkspaceId string = ''

module diagPolicy 'diagnostic-setting-policy.bicep' = [for config in configuration: {
  name: '${config.name}Deployment'
  params: {
    resourceName: config.name
    resourceType: config.type
    logs: config.logs
    metrics: config.metrics
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
    policyDefinitions: [for (config, index) in configuration: {
      policyDefinitionId: diagPolicy[index].outputs.policyDefinitionId
    }]
  }
}

// outputs
output initiativeDefinitionId string = diagnosticsInitiative.id
