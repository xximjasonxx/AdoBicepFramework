
targetScope = 'subscription'

param configuration object

module diagPolicy 'diagnostic-setting-policy.bicep' = [for config in items(configuration): {
  name: '${config.key}Deployment'
  params: {
    resourceName: config.key
    resourceType: config.value.type
    logs: config.value.logs
    metrics: config.value.metrics
  }
}]
