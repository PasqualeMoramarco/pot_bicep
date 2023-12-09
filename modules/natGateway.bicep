// * PARAMS
@description('Resources Group locations')
param location string

@description('Resources tags')
param tags object = {}

@description('Resources Name, most be an unique string without spaces')
@minLength(3)
@maxLength(25)
param natGatewayName string

@description('Resources Group locations')
param publicIPAddressID string

resource natgateway 'Microsoft.Network/natGateways@2022-07-01' = {
  name: natGatewayName
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    idleTimeoutInMinutes: 4
    publicIpAddresses: [
      {
        id: publicIPAddressID
      }
    ]
  }
}
