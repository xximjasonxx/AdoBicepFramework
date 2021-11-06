targetScope = 'subscription'

module acr '../bicep-modules/naming-convention/naming-convention-generic.bicep' = {
  name: 'policy-naming-convention-acr'
  params: {
    pattern: 'acr*'
    policyName: 'policy-naming-convention-acr'
    type: 'Microsoft.ContainerRegistry/registries'
    effect: 'Audit'
  }
}

module rg '../bicep-modules/naming-convention/naming-convention-generic.bicep' = {
  name: 'policy-naming-convention-rg'
  params: {
    pattern: 'rg-*'
    policyName: 'policy-naming-convention-rg'
    type: 'Microsoft.Resources/resourceGroups'
  }
}

// define the intiative
resource policySet 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: 'naming-convention-initiative'
  properties: {
    displayName: 'Naming Convention Policy Set'
    policyDefinitionGroups: [
      {
        category: 'StandardsEnforcement'
        name: 'StandardsEnforcement'
      }
    ]
    policyDefinitions: [
      {
        policyDefinitionId: acr.outputs.policyDefinitionId
      }
      {
        policyDefinitionId: rg.outputs.policyDefinitionId
      }
    ]
  }

  dependsOn: [
    acr
    rg
  ]
}

// assign the initiative
resource policySetAssignment 'Microsoft.Authorization/policyAssignments@2021-06-01' = {
  name: 'Enforce Naming Convention'
  location: 'EastUS'
  properties: {
    enforcementMode: 'Default'
    policyDefinitionId: policySet.id
  }
}
