targetScope='subscription'

@description('Resources Group location')
param location string

@description('Resources Name, must be an unique string without spaces')
@minLength(2)
@maxLength(60)
param resourceGroupName string

@description('Resources tags')
param tags object = {}

resource newRG 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}