targetScope = 'subscription'
param roleDefinitionId string
param initiativeIdentityPrincipalId string

resource initiativeRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(initiativeIdentityPrincipalId, roleDefinitionId)
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: initiativeIdentityPrincipalId
  }
}
