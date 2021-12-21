
targetScope = 'subscription'

param resourceForDiagnostics object
param location string
param logAnalyticsWorkspaceId string = ''
param storageAccountId string = ''
param eventHubId string = ''

var contributorRoleDefId = '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'

resource diagPolicy 'Microsoft.Authorization/policyDefinitions@2018-05-01' = [for config in items(resourceForDiagnostics): {
  name: 'enable-diagnostics-policy-${config.key}'
  properties: {
    displayName: 'Enable Diagnostics Policy - ${config.key}'
    metadata: {
      category: 'Monitoring'
    }
    mode: 'All'
    parameters: {}
    policyRule: {
      if: {
        field: 'type'
        equals: config.value.type
      }
      then: {
        effect: 'deployIfNotExists'
        details: {
          type: 'Microsoft.Insights/diagnosticSettings'
          roleDefinitionIds: [
            contributorRoleDefId
          ]
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                '$schema': 'http://schema.management.azure.com/schemas/2019-08-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                parameters: {
                  resourceName: {
                    type: 'String'
                  }
                  resourceId: {
                    type: 'String'
                  }
                }
                variables: {}
                resources: [
                  {
                    type: '${config.value.type}/providers/diagnosticSettings'
                    apiVersion: '2021-05-01-preview'
                    name: '[concat(parameters(\'resourceName\'), \'/Microsoft.Insights/all-diagnositcs\')]'
                    location: location
                    dependsOn: []
                    properties: {
                      scopes: [
                        '[parameters(\'resourceId\')]'
                      ]
                      workspaceId: empty(logAnalyticsWorkspaceId) ? null : logAnalyticsWorkspaceId
                      storageAccountId: empty(storageAccountId) ? null : storageAccountId
                      eventHubId: empty(eventHubId) ? null : eventHubId
                      metrics: [for metric in config.value.metrics: {
                          category: metric
                          timeGrain: null
                          enabled: true
                          retentionPolicy: {
                            enabled: false
                            days: 0
                          }
                      }]
                      logs: [for log in config.value.logs: {
                        category: log
                        enabled: true
                      }]
                    }
                  }
                ]
                outputs: {}
              }
              parameters: {
                resourceName: {
                  value: '[field(\'name\')]'
                }
                resourceId: {
                  value: '[field(\'id\')]'
                }
              }
            }
          }
        }
      }
    }
  }
}]

// create the initiative
resource diagnosticsInitiative 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: 'diagnostics-initiative'
  properties: {
    metadata: {
      category: 'Monitoring'
    }
    parameters: {
    }
    policyDefinitions: [for index in range(0, length(resourceForDiagnostics)): {
      policyDefinitionId: diagPolicy[index].id
    }]
  }

  dependsOn: [
    diagPolicy
  ]
}

output diagnosticInitiatveId string = diagnosticsInitiative.id
