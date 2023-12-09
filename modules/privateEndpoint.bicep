@description('Resources Group location')
param location string = resourceGroup().location

// param environment string

@description('Resources tags')
param tags object

param privateEndpointName string
param resourceID string
param virtualNetworkSubnetId string
param groupIds string
param privateDnsZoneConfigs object

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = {
  name: privateEndpointName
  location: location
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: resourceID
          groupIds: [groupIds]
          privateLinkServiceConnectionState: {
            status: 'Approved'
            actionsRequired: 'None'
          }
        }
      }
    ]
    manualPrivateLinkServiceConnections: []
    subnet: {
      id: virtualNetworkSubnetId
    }
    ipConfigurations: []
    customDnsConfigs: []
  }
}

resource privateDnsZoneConfig 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-07-01' = if(!empty(privateDnsZoneConfigs)) {
  parent: privateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [privateDnsZoneConfigs]
  }
}
