
param thisSubId string
param thisRgName string
param thisVnetName string

param targetSubId string
param targetRgName string
param targetVnetName string

// create spoke to hub peering
module spokeToHubPeering './do-peering.bicep' = {
  name: 'SpokeToHubPeering'
  scope: resourceGroup(thisSubId, thisRgName)
  params: {
    thisVnetResourceName: thisVnetName
    targetVnetId: resourceId(targetSubId, targetRgName, 'Microsoft.Network/virtualNetworks', targetVnetName)
    targetVnetResourceName: targetVnetName
  }
}

// create hub to spoke peering
module hpokeToSpokePeering './do-peering.bicep' = {
  name: 'HubToSpokePeering'
  scope: resourceGroup(targetSubId, targetRgName)
  params: {
    thisVnetResourceName: targetVnetName
    targetVnetId: resourceId(thisSubId, thisRgName, 'Microsoft.Network/virtualNetworks', thisVnetName)
    targetVnetResourceName: thisVnetName
  }
}
