@description('Resources Group location')
param location string

@description('Resources tags')
param tags object = {}

@minLength(5)
@maxLength(50)
@description('Name of the azure container registry (must be globally unique)')
param acrName string

@allowed([
  'Basic'
  'Standard'
  'Premium'
])
@description('Tier of your Azure Container Registry.')
param acrSku string = 'Basic'

@description('Container properties.')
param containerProperties object = {
  adminUserEnabled: false
}

// azure container registry
resource acr 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' = {
  name: acrName
  location: location
  tags: tags
  sku: {
    name: acrSku
  }
  properties: containerProperties
}
