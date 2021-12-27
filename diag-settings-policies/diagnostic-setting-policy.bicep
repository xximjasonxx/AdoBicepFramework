
targetScope = 'subscription'
var contributorRoleDefId = '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'

param resourceName string
param resourceType string
param logs array
param metrics array

param logAnalyticsWorkspaceId string = ''
param storageAccountId string = ''
param eventHubId string = ''

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
var resourceTypes = resourceType == 'Microsoft.Storage/storageAccounts' ? [
    {
      type: resourceType
      name: '/'
      logs: []    // we know storage accounts have no logs
      metrics: metricValues
    }
    {
      type: '${resourceType}/blobServices'
      name: '/default/'
      logs: logValues
      metrics: metricValues
    }
    {
      type: '${resourceType}/queueServices'
      name: '/default/'
      logs: logValues
      metrics: metricValues
    }
    {
      type: '${resourceType}/tableServices'
      name: '/default/'
      logs: logValues
      metrics: metricValues
    }
    {
      type: '${resourceType}/fileServices'
      name: '/default/'
      logs: logValues
      metrics: metricValues
    }
  ] : [
    {
      type: resourceType
      name: '/'
      logs: logValues
      metrics: metricValues
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
                resourceName: {
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
                  resourceName: {
                    type: 'string'
                  }
                  location: {
                    type: 'string'
                  }
                }
                resources: [for resource in resourceTypes: {
                  type: '${resource.type}/providers/diagnosticSettings'
                  apiVersion: '2021-05-01-preview'
                  location: '[parameters(\'location\')]'
                  name: '[concat(parameters(\'resourceName\'), \'${resource.name}\', \'Microsoft.Insights/diagnosticSettings\')]'
                  properties: {
                    workspaceId: logAnalyticsWorkspaceId
                    storageAccountId: storageAccountId
                    logs: resource.logs
                    metrics: resource.metrics
                  }
                }]
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
