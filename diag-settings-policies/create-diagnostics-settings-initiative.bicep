
targetScope = 'subscription'

@minLength(1)
param resourceForDiagnostics array
param location string
param logAnalyticsWorkspaceId string = ''
param storageAccountId string = ''
param eventHubId string = ''

var contributorRoleDefId = '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'

resource diagPolicy 'Microsoft.Authorization/policyDefinitions@2018-05-01' = [for config in resourceForDiagnostics: {
  name: 'enable-diagnostics-policy-${config.simpleName}'
  properties: {
    displayName: 'Enable Diagnostics Policy - ${config.simpleName}'
    metadata: {
      category: 'Monitoring'
    }
    mode: 'All'
    parameters: {
    }

    policyRule: {
      if: {
        field: 'type'
        equals: config.type
      }
      then: {
        effect: 'deployIfNotExists'
        details: {
          type: 'Microsoft.Insights/diagnosticSettings'
          name: 'setByPolicy'
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
                }
                variables: {}
                resources: [
                  {
                    type: '${config.type}/providers/diagnosticSettings'
                    apiVersion: '2021-05-01-preview'
                    name: '[parameters(\'resourceName\']/Microsoft.Insights/diag-settings'
                    location: location
                    dependsOn: []
                    properties: {
                      workspaceId: empty(logAnalyticsWorkspaceId) ? null : logAnalyticsWorkspaceId
                      storageAccountId: empty(storageAccountId) ? null : storageAccountId
                      eventHubId: empty(eventHubId) ? null : eventHubId
                      metrics: [
                        {
                          category: 'AllMetrics'
                          timeGrain: null
                          enabled: true
                          retentionPolicy: {
                            enabled: false
                            days: 0
                          }
                        }
                      ]
                    }
                  }
                ]
                outputs: {}
              }
              parameters: {
                resourceName: {
                  value: '[field(\'name\')]'
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
    policyDefinitions: [for (config, i) in resourceForDiagnostics: {
      policyDefinitionId: diagPolicy[i].id
    }]
  }

  dependsOn: [
    diagPolicy
  ]
}

output diagnosticInitiatveId string = diagnosticsInitiative.id
