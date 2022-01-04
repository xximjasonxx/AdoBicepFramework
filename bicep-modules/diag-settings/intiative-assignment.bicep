
param intiativeDefinitionId string
param userIdentityResourceId string

resource policyAssignment 'Microsoft.Authorization/policyAssignments@2021-06-01' = {
  name: 'assignDiagnosticsSettingsInitiative'
  location: 'eastus'
  properties: {
    policyDefinitionId: intiativeDefinitionId
    displayName: 'AssignDiagnosticsSettingsInitiative'
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userIdentityResourceId}': {}
    }
  }
}
