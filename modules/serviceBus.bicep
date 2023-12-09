@description('Resources Group location')
param location string

@description('Resources tags')
param tags object = {}

param skuName string
param skuTier string
param skuCapacity int

@description('Service Name, must be an unique string without spaces, max lenght is 255 characters')
@minLength(1)
@maxLength(150)
param serviceBusName string

param logAnalyticsName string = ''

resource serviceBus 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' = {
  name: serviceBusName
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
    zoneRedundant: false
  }
}

resource rootManageSharedAccessKey 'Microsoft.ServiceBus/namespaces/AuthorizationRules@2022-01-01-preview' = {
  parent: serviceBus
  name: 'RootManageSharedAccessKey'
  properties: {
    rights: [
      'Listen'
      'Manage'
      'Send'
    ]
  }
}

resource defaultSharedAccessKey 'Microsoft.ServiceBus/namespaces/AuthorizationRules@2022-01-01-preview' = {
  parent: serviceBus
  name: 'DefaultSharedAccessKey'
  properties: {
    rights: [
      'Listen'
      'Send'
    ]
  }
}

resource networkRuleSets 'Microsoft.ServiceBus/namespaces/networkRuleSets@2022-01-01-preview' = {
  parent: serviceBus
  name: 'default'
  properties: {
    publicNetworkAccess: 'Enabled'
    defaultAction: 'Allow'
    virtualNetworkRules: []
    ipRules: []
  }
}

// GESTIONE LOG ANALYTICS
resource workspace 'microsoft.operationalinsights/workspaces@2021-12-01-preview' existing = {
  name: logAnalyticsName
}

// GESTIONE DIAGNOSTIC SETTINGS
resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'SendToLAW'
  scope: serviceBus
  properties: {
    workspaceId: workspace.id
    metrics: [
      {
        category: 'AllMetrics'
        enabled: false
      }
    ]
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: false
      }
      {
        categoryGroup: 'audit'
        enabled: true
      }
    ]
  }
}

output serviceBusId string = serviceBus.id

// resource lockResource 'Microsoft.Authorization/locks@2020-05-01' = {
//   name: '${serviceBusName}-lock'
//   scope: serviceBus
//   properties: {
//     level: 'CanNotDelete'
//     notes: 'Component managed by Bicep, and should not be deleted.'
//   }
// }
