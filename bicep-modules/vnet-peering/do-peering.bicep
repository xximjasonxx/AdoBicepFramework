
param thisVnetResourceName string
param targetVnetId string
param targetVnetResourceName string

resource peering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-02-01' = {
  name: '${thisVnetResourceName}/${thisVnetResourceName}-to-${targetVnetResourceName}-peering'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: targetVnetId
    }
  }
}
