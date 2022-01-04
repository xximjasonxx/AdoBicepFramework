targetScope = 'subscription'
param intiativeDefinitionId string

resource policyAssignment 'Microsoft.Authorization/policyAssignments@2021-06-01' = {
  name: 'assignDiagnosticsSettingsInitiative'
  location: 'eastus'
  properties: {
    policyDefinitionId: intiativeDefinitionId
    displayName: 'AssignDiagnosticsSettingsInitiative'
  }
  identity: {
    type: 'SystemAssigned'
  }
}

// outputs
output initiativeAssignmentPrincipalId string = policyAssignment.identity.principalId
