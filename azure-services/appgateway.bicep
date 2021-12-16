
@allowed([
  'eastus'
  'westus'
])
param resourceLocation string

param isSecondary bool
param gatewaySubnetId string
param hubIdentityId string
param publicIpResourceId string

param diagnosticsWorkspaceResourceId string = ''
param diagnosticsStorageAccountId string = ''
param sslCertUri string

// create app gateway
var appGW_name = 'appgw-hub-networking-${isSecondary ? 'secondary' : 'primary'}'
module appGateway '../bicep-modules/appgateway-complete/appgateway-complete.bicep' = {
  name: 'gatewayDeploy'
  params: {
    gatewayName: appGW_name
    resourceLocation: resourceLocation
    gatewaySubnetId: gatewaySubnetId
    identityId: hubIdentityId
    appGatewayPipId: publicIpResourceId
    routeConfigurations: [
      {
        name: 'testRoute'
        destinationIp: '10.100.17.4'
        port: 443
        protocol: 'Https'
        hostName: 'func-m2genroutetest.ase-functionapptest.appserviceenvironment.net'
        externalHostName: 'm2gen-demo-01.ringen.us'
        probeConfig: {
          path: '/'
          codes: [
            '200-399'
            '401'
          ]
        }
        sslConfig: {
          keyVaultSecretId: sslCertUri
          certificateData: ''
          certificatePassword: ''
        }
      }
    ]
  }
}

// enable diagnostics on app gateway
module appGatewayDiagnostics '../bicep-modules/appgateway-diagnostic-settings/appgateway-diagnostic-settings.bicep' = {
  name: 'gatewayDiagnostics'
  params: {
    gatewayName: appGW_name
    storageAccountId: diagnosticsStorageAccountId
    lawId: diagnosticsWorkspaceResourceId
  }
  dependsOn: [
    appGateway
  ]
}
