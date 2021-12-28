
targetScope = 'subscription'
var contributorRoleDefId = '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'

param resourceName string
param resourceType string
param logs array
param metrics array

param logAnalyticsWorkspaceId string = ''
param storageAccountId string = ''
param eventHubAuthRuleId string = ''
param eventHubName string = ''

// build the values log array
var logValues = [for logValue in logs: {
  category: logValue
  enabled: true
}]

// build the values metric array
var metricValues = [for metricValue in metrics: {
  category: metricValue
  timeGrain: null
  enabled: true
  retentionPolicy: {
    enabled: false
    days: 0
  }
}]

// build an array of the actual diagnostic resource types we are going to add (this is only applicable for storage accounts)
var resources = resourceType == 'Microsoft.Storage/storageAccounts' ? [
    {
      type: '${resourceType}/providers/diagnosticSettings'
      apiVersion: '2021-05-01-preview'
      name: '[concat(parameters(\'serviceName\'), \'/Microsoft.Insights/diagnosticSettings\')]'
      location: '[parameters(\'location\')]'
      properties: {
        workspaceId: empty(logAnalyticsWorkspaceId) ? null : logAnalyticsWorkspaceId
        storageAccountId: empty(storageAccountId) ? null : storageAccountId
        eventHubAuthorizationRuleId: empty(eventHubAuthRuleId) ? null : eventHubAuthRuleId
        eventHubName: empty(eventHubName) ? null : eventHubName
        logs: []    // we know storage accounts have no logs
        metrics: metricValues
      }
    }
    {
      type: '${resourceType}/providers/diagnosticSettings/blobServices'
      apiVersion: '2021-05-01-preview'
      name: '[concat(parameters(\'serviceName\'), \'/default/\', \'Microsoft.Insights/diagnosticSettings\')]'
      properties: {
        workspaceId: empty(logAnalyticsWorkspaceId) ? null : logAnalyticsWorkspaceId
        storageAccountId: empty(storageAccountId) ? null : storageAccountId
        eventHubAuthorizationRuleId: empty(eventHubAuthRuleId) ? null : eventHubAuthRuleId
        eventHubName: empty(eventHubName) ? null : eventHubName
        logs: logValues
        metrics: metricValues
      }
    }
    {
      type: '${resourceType}/providers/diagnosticSettings/queueServices'
      apiVersion: '2021-05-01-preview'
      name: '[concat(parameters(\'serviceName\'), \'/default/\', \'Microsoft.Insights/diagnosticSettings\')]'
      properties: {
        workspaceId: empty(logAnalyticsWorkspaceId) ? null : logAnalyticsWorkspaceId
        storageAccountId: empty(storageAccountId) ? null : storageAccountId
        eventHubAuthorizationRuleId: empty(eventHubAuthRuleId) ? null : eventHubAuthRuleId
        eventHubName: empty(eventHubName) ? null : eventHubName
        logs: logValues
        metrics: metricValues
      }
    }
    {
      type: '${resourceType}/providers/diagnosticSettings/tableServices'
      apiVersion: '2021-05-01-preview'
      name: '[concat(parameters(\'serviceName\'), \'/default/\', \'Microsoft.Insights/diagnosticSettings\')]'
      properties: {
        workspaceId: empty(logAnalyticsWorkspaceId) ? null : logAnalyticsWorkspaceId
        storageAccountId: empty(storageAccountId) ? null : storageAccountId
        eventHubAuthorizationRuleId: empty(eventHubAuthRuleId) ? null : eventHubAuthRuleId
        eventHubName: empty(eventHubName) ? null : eventHubName
        logs: logValues
        metrics: metricValues
      }
    }
    {
      type: '${resourceType}/providers/diagnosticSettings/fileServices'
      apiVersion: '2021-05-01-preview'
      name: '[concat(parameters(\'serviceName\'), \'/default/\', \'Microsoft.Insights/diagnosticSettings\')]'
      properties: {
        workspaceId: empty(logAnalyticsWorkspaceId) ? null : logAnalyticsWorkspaceId
        storageAccountId: empty(storageAccountId) ? null : storageAccountId
        eventHubAuthorizationRuleId: empty(eventHubAuthRuleId) ? null : eventHubAuthRuleId
        eventHubName: empty(eventHubName) ? null : eventHubName
        logs: logValues
        metrics: metricValues
      }
    }
  ] : [
    {
      type: '${resourceType}/providers/diagnosticSettings'
      apiVersion: '2021-05-01-preview'
      name: '[concat(parameters(\'serviceName\'), \'/Microsoft.Insights/diagnosticSettings\')]'
      properties: {
        workspaceId: empty(logAnalyticsWorkspaceId) ? null : logAnalyticsWorkspaceId
        storageAccountId: empty(storageAccountId) ? null : storageAccountId
        eventHubAuthorizationRuleId: empty(eventHubAuthRuleId) ? null : eventHubAuthRuleId
        eventHubName: empty(eventHubName) ? null : eventHubName
        logs: logValues
        metrics: metricValues
      }
    }
  ]

resource policyDef 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: '${resourceName}-diagnostics'
  properties: {
    displayName: '${resourceName} Diagnostics'
    metadata: {
      category: 'Diagnostics'
    }
    mode: 'All'
    policyRule: {
      if: {
        field: 'type'
        equals: resourceType
      }
      then: {
        details: {
          type: 'Microsoft.Insights/diagnosticSettings'
          roleDefinitionIds: [
            contributorRoleDefId
          ]
          deployment: {
            properties: {
              mode: 'Incremental'
              parameters: {
                serviceName: {
                  value: '[field(\'name\')]'
                }
                location: {
                  value: '[field(\'location\')]'
                }
              }
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                parameters: {
                  serviceName: {
                    type: 'string'
                  }
                  location: {
                    type: 'string'
                  }
                }
                resources: resources
              }
            }
          }
        }
        effect: 'DeployIfNotExists'
      }
    }
    policyType: 'Custom'
  }
}

// outputs
output policyDefinitionId string = policyDef.id
