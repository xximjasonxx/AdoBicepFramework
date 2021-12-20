
param thisSubId string = ''
param thisRgName string
param thisVnetName string

param targetSubId string = ''
param targetRgName string
param targetVnetName string

// create spoke to hub peering
module thisToHubPeering './do-peering.bicep' = {
  name: 'thisToHubPeering'
  scope: thisSubId == '' ? resourceGroup(thisRgName) : resourceGroup(thisSubId, thisRgName)
  params: {
    thisVnetResourceName: thisVnetName
    targetVnetId: targetSubId == '' ? resourceId(targetRgName, 'Microsoft.Network/virtualNetworks', targetVnetName) : resourceId(targetSubId, targetRgName, 'Microsoft.Network/virtualNetworks', targetVnetName)
    targetVnetResourceName: targetVnetName
  }
}

// create hub to spoke peering
module hpokeToSpokePeering './do-peering.bicep' = {
  name: 'hubToThisPeering'
  scope: targetSubId == '' ? resourceGroup(targetRgName) : resourceGroup(targetSubId, targetRgName)
  params: {
    thisVnetResourceName: targetVnetName
    targetVnetId: thisSubId == '' ? resourceId(thisRgName, 'Microsoft.Network/virtualNetworks', thisVnetName) : resourceId(thisSubId, thisRgName, 'Microsoft.Network/virtualNetworks', thisVnetName)
    targetVnetResourceName: thisVnetName
  }
}
