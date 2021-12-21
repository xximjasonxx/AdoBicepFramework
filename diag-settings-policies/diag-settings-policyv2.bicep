
targetScope = 'subscription'

var location = 'eastus'
var logAnalyticsWorkspaceId = '/subscriptions/cd35503e-9e28-4b2b-8445-45fc816ba088/resourcegroups/rg-sandbox/providers/microsoft.operationalinsights/workspaces/law-testappjx01'
//param storageAccountId string = ''
//param eventHubId string = ''

var configs = [
  {
    simpleName: 'AppService'
    type: 'Microsoft.Web/sites'
  }
  {
    simpleName: 'VirtualNetwork'
    type: 'Microsoft.Network/virtualNetworks'
  }
  {
    simpleName: 'AzureFirewall'
    type: 'Microsoft.Network/azureFirewalls'
  }
  {
    simpleName: 'ApplicationGateway'
    type: 'Microsoft.Network/applicationGateways'
  }
  {
    simpleName: 'Bastion'
    type: 'Microsoft.Network/bastionHosts'
  }
  {
    simpleName: 'NSG'
    type: 'Microsoft.Network/networkSecurityGroups'
  }
  {
    simpleName: 'PIP'
    type: 'Microsoft.Network/publicIPAddresses'
  }
  {
    simpleName: 'KeyVault'
    type: 'Microsoft.KeyVault/vaults'
  }
]

module diagnosticInitiative 'create-diagnostics-settings-initiative.bicep' = {
  name: 'create-diagnostics-settings-initiative'
  params: {
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    resourceForDiagnostics: configs
  }
}

resource initiativeAssignment 'Microsoft.Authorization/policyAssignments@2020-09-01' = {
  name: 'enable-diagnostics-policy-assignment'
  location: 'eastus'
  properties: {
    policyDefinitionId: diagnosticInitiative.outputs.diagnosticInitiatveId
    displayName: 'Enforce Diagnostic Settings Initiative'
  }
  identity: {
    type: 'SystemAssigned'
  }
}

/*resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(diagPolicyName.name, 'eastus')
  properties: {
    roleDefinitionId: contributorRoleDefID
    principalId: policyAssignment.identity.principalId
  }
}
*/
