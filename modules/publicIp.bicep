@description('Resources Group location')
param location string

@description('Resources tags')
param tags object = {}

@description('Resources Name, must be an unique string without spaces')
@minLength(1)
@maxLength(80)
param publicIpName string

param domainNameLabel string = ''


resource publicIp 'Microsoft.Network/publicIPAddresses@2023-04-01' = {
  name: publicIpName
  location: location
  tags: tags
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  zones: [
  ]
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    ipTags: []
    dnsSettings: (domainNameLabel != '' ? {
      domainNameLabel: domainNameLabel
    } : null)
  }
}

output id string = publicIp.id
