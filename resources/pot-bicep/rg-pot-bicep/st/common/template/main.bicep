// * PARAMS
param location string = resourceGroup().location

@description('Azure Environment')
param environment string

@description('Resources Name')
param resourceName string

@description('Resources tags')
param tags object = {}

@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_ZRS'
  'Premium_LRS'
])
@description('Resources Sku Type')
param skuType string = 'Standard_LRS'

@allowed([
  'StorageV2'
])
@description('Resources Sku Kind')
param storageAccountKind string = 'StorageV2'

@allowed([
  'Disabled'
  'Enabled'
])
@description('Resources access from the public Network')
param publicNetworkAccess string = 'Disabled'

@description('Resources Blob component access from the public Network')
param allowBlobPublicAccess bool = true

@description('Resources Blob component Encryption')
param encryption object = {
  requireInfrastructureEncryption: false
  keySource: 'Microsoft.Storage'
}

@description('Resources networkAcls ip rules')
param networkAclsIpRules array = []

@allowed([
  'Hot'
])
@description('Resources accessTier type')
param accessTier string = 'Hot'

param containersList array = []
param shareList array = []
param tableList array = []
param queueList array = []

param virtualNetworkRules array = []

// * VARIABLES
var finalTags = union(resourceGroup().tags, tags)
var finalResourceName = '${resourceName}${toLower(environment)}${azLocation.outputs.code}'

// * RESOURCES
module azLocation '../../../../../../modules/azLocations.bicep' = {
  name: '${deployment().name}.location'
  params: {
    location: location
  }
}

module storageAccountModule '../../../../../../modules/storageAccounts.bicep' = {
  name: '${deployment().name}.storageAccountModule'
  params: {
    location: azLocation.outputs.name
    tags: finalTags
    skuType: skuType
    storageAccountKind: storageAccountKind
    #disable-next-line BCP334 BCP335
    storageAccountName: finalResourceName
    virtualNetworkRules: virtualNetworkRules
    publicNetworkAccess: publicNetworkAccess
    allowBlobPublicAccess: allowBlobPublicAccess
    encryption: encryption
    networkAclsIpRules: networkAclsIpRules
    accessTier: accessTier
    tableList: tableList
    containersList: containersList
    shareList: shareList
    queueList: queueList
    networkAclsDefaultAction: 'Allow'
  }
}
