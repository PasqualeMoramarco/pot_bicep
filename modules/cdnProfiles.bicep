@description('Resources Group location')
param location string

@description('Resources Name')
param cdnProfilesName string

@description('Resources tags')
param tags object = {}


resource cdnVerizonProfile 'Microsoft.Cdn/profiles@2022-11-01-preview' = {
  name: cdnProfilesName
  location: location
  tags: tags
  sku: {
    name: 'Standard_Verizon'
  }
  kind: 'cdn'
  properties: {
    extendedProperties: {}
  }
}
