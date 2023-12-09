@description('Resources Group location')
param location string

@description('Resources tags')
param tags object = {}

param skuName string
param skuTier string
param skuCapacity int
param zoneRedundant bool = true

@description('Service Name, must be an unique string without spaces, max lenght is 255 characters')
@minLength(1)
@maxLength(150)
param nameSpaceName string

resource nameSpace 'Microsoft.EventHub/namespaces@2022-10-01-preview' = {
  name: nameSpaceName
  location: location
  tags: tags
  sku: {
    name: skuName
    tier: skuTier
    capacity: skuCapacity
  }
  properties: {
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
    zoneRedundant: zoneRedundant
    isAutoInflateEnabled: true
    maximumThroughputUnits: 5
  }
}

resource RootManageSharedAccessKey 'Microsoft.EventHub/namespaces/AuthorizationRules@2022-01-01-preview' = {
  parent: nameSpace
  name: 'RootManageSharedAccessKey'
  properties: {
    rights: [
      'Listen'
      'Manage'
      'Send'
    ]
  }
}

resource DefaultSharedAccessKey 'Microsoft.EventHub/namespaces/AuthorizationRules@2022-01-01-preview' = {
  parent: nameSpace
  name: 'DefaultSharedAccessKey'
  properties: {
    rights: [
      'Listen'
      'Send'
    ]
  }
}

resource networkRuleSets 'Microsoft.EventHub/namespaces/networkRuleSets@2022-01-01-preview' = {
  parent: nameSpace
  name: 'default'
  properties: {
    publicNetworkAccess: 'Enabled'
    defaultAction: 'Allow'
    virtualNetworkRules: []
    ipRules: []
  }
}
