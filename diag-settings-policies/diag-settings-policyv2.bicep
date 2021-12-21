
targetScope = 'subscription'

var location = 'eastus'
var logAnalyticsWorkspaceId = '/subscriptions/cd35503e-9e28-4b2b-8445-45fc816ba088/resourcegroups/rg-sandbox/providers/microsoft.operationalinsights/workspaces/law-testappjx01'
//param storageAccountId string = ''
//param eventHubId string = ''

var configs = {
  appService: {
    type: 'Microsoft.Web/sites'
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
  virtualNetwork: {
    type: 'Microsoft.Network/virtualNetworks'
    logs: [
      'VMProtectionAlerts'
    ]
    metrics: [
      'AllMetrics'
    ]
  }
  azureFirewall: {
    type: 'Microsoft.Network/azureFirewalls'
    logs: [
      'AzureFirewallApplicationRule'
      'AzureFirewallNetworkRule'
      'AzureFirewallDnsProxy'
    ]
    metrics: [
      'AllMetrics'
    ]
  }
  applicationGateway: {
    type: 'Microsoft.Network/applicationGateways'
    logs: [
      'ApplicationGatewayAccessLog'
      'ApplicationGatewayPerformanceLog'
      'ApplicationGatewayFirewallLog'
    ]
    metrics: [
      'AllMetrics'
    ]
  }
  bastion: {
    type: 'Microsoft.Network/bastionHosts'
    logs: [
      'BastionAuditLogs'
    ]
    metrics: [
      'AllMetrics'
    ]
  }
  nsg: {
    type: 'Microsoft.Network/networkSecurityGroups'
    logs: [
      'NetworkSecurityGroupEvent'
      'NetworkSecurityGroupRuleCounter'
    ]
    metrics: []
  }
  pip: {
    type: 'Microsoft.Network/publicIPAddresses'
    logs: [
      'DDoSProtectionNotifications'
      'DDoSMitigationFlowLogs'
      'DDoSMitigationReports'
    ]
    metrics: [
      'AllMetrics'
    ]
  }
  keyVault: {
    type: 'Microsoft.KeyVault/vaults'
    logs: [
      'AuditEvent'
      'AzurePolicyEvaluationDetails'
    ]
    metrics: [
      'AllMetrics'
    ]
  }
}

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
