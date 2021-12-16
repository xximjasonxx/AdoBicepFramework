
@allowed([
  'eastus'
  'westus'
])
param resourceLocation string

param gatewayName string
param identityId string
param gatewaySubnetId string
param appGatewayPipId string

param routeConfigurations array

// build the variables ////////////////////////////////////////////////////////////////
var addressPools = [for routeConfig in routeConfigurations: {
  name: '${routeConfig.name}-pool'
  ipAddress: routeConfig.destinationIp
}]

var httpSettings = [for routeConfig in routeConfigurations: {
  name: '${routeConfig.name}-settings'
  port: routeConfig.port
  protocol: routeConfig.protocol
  hostname: routeConfig.hostname
  cookieBasedAffinity: 'Disabled'
  pickHostNameFromBackendAddress: false
  requestTimeout: 20
  probeName: routeConfig.probeConfig == null ? '' : '${routeConfig.name}-probe'
}]

var probes = [for routeConfig in routeConfigurations: {
  name: '${routeConfig.name}-probe'
  path: routeConfig.probeConfig.path
  host: routeConfig.hostname
  pickHostNameFromBackendHttpSettings: false
  matchingCodes: routeConfig.probeConfig.codes
  protocol: routeConfig.protocol
  minServers: 0
}]

var listeners = [for routeConfig in routeConfigurations: {
  name: '${routeConfig.name}-listener'
  frontEndIpConfigName: 'appGwPublicFrontendIp'
  frontendPort: routeConfig.port
  protocol: routeConfig.protocol
  hostName: routeConfig.externalHostname
  requireServerNameIndication: true
  sslCertConfigName: routeConfig.sslConfig == null ? '' : '${routeConfig.name}-cert'
}]

var routingRules = [for routeConfig in routeConfigurations: {
  name: '${routeConfig.name}-rule'
  type: 'Basic'
  httpListenerName: '${routeConfig.name}-listener'
  backendAddressPoolName: '${routeConfig.name}-pool'
  backendHttpSettingsName: '${routeConfig.name}-settings'
}]

var sslCertificates = [for routeConfig in routeConfigurations: {
  name: '${routeConfig.name}-cert'
  data: empty(routeConfig.sslConfig.certificateData) ? null : routeConfig.sslConfig.certificateData
  password: empty(routeConfig.sslConfig.certificatePassword) ? null : routeConfig.sslConfig.certificatePassword
  secretId: empty(routeConfig.sslConfig.keyVaultSecretId) ? null : routeConfig.sslConfig.keyVaultSecretId
}]

//////////////////////////////////////////////////////////////////////////////////////

// deploy the gateway
resource appGw_hub 'Microsoft.Network/applicationGateways@2021-02-01' = {
  name: gatewayName
  location: resourceLocation
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identityId}': {}
    }
  }
  properties: {
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
    }

    sslCertificates: [for sslCertificate in sslCertificates: {
      name: sslCertificate.name
      properties: {
        data: sslCertificate.data
        password: sslCertificate.password
        keyVaultSecretId: sslCertificate.secretId
      }
    }]

    backendAddressPools: [for addressPool in addressPools: {
      name: addressPool.name
      properties: {
        backendAddresses: [
          {
            ipAddress: addressPool.ipAddress
          }
        ]
      }
    }]

    backendHttpSettingsCollection: [for httpSetting in httpSettings: {
      name: httpSetting.name
      properties: {
        port: httpSetting.port
        protocol: httpSetting.protocol
        cookieBasedAffinity: httpSetting.cookieBasedAffinity
        requestTimeout: httpSetting.requestTimeout
        hostName: empty(httpSetting.hostname) ? null : httpSetting.hostname
        pickHostNameFromBackendAddress: httpSetting.pickHostNameFromBackendAddress
        probe: empty(httpSetting.probeName) ? null : {
          id: '${resourceId('Microsoft.Network/applicationGateways', gatewayName)}/probes/${httpSetting.probeName}'
        }
      }
    }]

    httpListeners: [for listener in listeners: {
      name: listener.name
      properties: {
        frontendIPConfiguration: {
          id: '${resourceId('Microsoft.Network/applicationGateways', gatewayName)}/frontendIPConfigurations/${listener.frontEndIpConfigName}'
        }
        frontendPort: {
          id: '${resourceId('Microsoft.Network/applicationGateways', gatewayName)}/frontendPorts/port_${listener.frontendPort}'
        }
        hostName: listener.hostName
        protocol: listener.protocol
        requireServerNameIndication: listener.requireServerNameIndication
        sslCertificate: empty(listener.sslCertConfigName) ? null : {
          id: '${resourceId('Microsoft.Network/applicationGateways', gatewayName)}/sslCertificates/${listener.sslCertConfigName}'
        }
      }
    }]

    requestRoutingRules: [for routingRule in routingRules: {
      name: routingRule.name
      properties: {
        ruleType: routingRule.type
        httpListener: {
          id: '${resourceId('Microsoft.Network/applicationGateways', gatewayName)}/httpListeners/${routingRule.httpListenerName}'
        }
        backendAddressPool: {
          id: '${resourceId('Microsoft.Network/applicationGateways', gatewayName)}/backendAddressPools/${routingRule.backendAddressPoolName}'
        }
        backendHttpSettings: {
          id: '${resourceId('Microsoft.Network/applicationGateways', gatewayName)}/backendHttpSettingsCollection/${routingRule.backendHttpSettingsName}'
        }
      }
    }]

    probes: [for probe in probes: {
      name: probe.name
      properties: {
        path: probe.path
        protocol: probe.protocol
        host: probe.host
        interval: 15
        timeout: 15
        unhealthyThreshold: 3
        pickHostNameFromBackendHttpSettings: probe.pickHostNameFromBackendHttpSettings
        minServers: probe.minServers
        match: {
          statusCodes: probe.matchingCodes
        }
      }
    }]

    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: gatewaySubnetId
          }
        }
      }
    ]
    trustedRootCertificates: []
    trustedClientCertificates: []
    sslProfiles: []
    frontendIPConfigurations: [
      {
        name: 'appGwPublicFrontendIp'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: appGatewayPipId
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_443'
        properties: {
          port: 443
        }
      }
      {
        name: 'port_80'
        properties: {
          port: 80
        }
      }
    ]
    urlPathMaps: []
    rewriteRuleSets: []
    redirectConfigurations: []
    privateLinkConfigurations: []
    webApplicationFirewallConfiguration: {
      enabled: true
      firewallMode: 'Prevention'
      ruleSetType: 'OWASP'
      ruleSetVersion: '3.1'
      disabledRuleGroups: []
      exclusions: []
      requestBodyCheck: true
      maxRequestBodySizeInKb: 128
      fileUploadLimitInMb: 750
    }
    enableHttp2: false
    autoscaleConfiguration: {
      minCapacity: 4
      maxCapacity: 125
    }
  }
}

// outputs
output gatewayId string = appGw_hub.id
