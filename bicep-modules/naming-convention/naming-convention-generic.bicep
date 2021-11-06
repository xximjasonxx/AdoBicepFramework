targetScope = 'subscription'
param pattern string
param policyName string
param type string

@allowed([
  'Deny'
  'Audit'
  'Disabled'
])
param effect string = 'Audit'

resource genericPolicy 'Microsoft.Authorization/policyDefinitions@2020-03-01' = {
  name: policyName
  properties: {
    policyType: 'Custom'
    mode: 'All'
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: type
          }
          {
            field: 'name'
            notLike: pattern
          }
        ]
      }
      then: {
        effect: effect
      }
    }
  }
}

output policyDefinitionId string = genericPolicy.id
