@description('Resources Group location')
param location string

@description('Resources tags')
param tags object = {}

param resourceName string

@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Enabled'

param enablePurgeProtection bool = false

param logAnalyticsName string = ''
param diagnosticSettingsName string = ''

param configurationStoreKeys array = []

resource configurationStore 'Microsoft.AppConfiguration/configurationStores@2023-03-01' = {
  name: resourceName
  location: location
  sku: {
    name: 'standard'
  }
  tags: tags
  properties: {
    encryption: {}
    publicNetworkAccess: publicNetworkAccess
    disableLocalAuth: false
    softDeleteRetentionInDays: 7
    enablePurgeProtection: enablePurgeProtection
  }

  resource configStoreKeyValue 'keyValues' = [for item in configurationStoreKeys: {
    name: item.key
    properties: {
      value: item.value
      contentType: item.content_type
    }
  }]
}

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = if (!empty(logAnalyticsName )) {
  name: (!empty(logAnalyticsName) ? logAnalyticsName : 'placesholder')
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(diagnosticSettingsName)) {
  name: (!empty(diagnosticSettingsName) ? diagnosticSettingsName : 'placesholder')
  scope: configurationStore
  properties: {
    workspaceId: logAnalytics.id
    logs: [
      {
        categoryGroup:'audit'
        enabled: true
      }
    ]
    logAnalyticsDestinationType: 'AzureDiagnostics'
  }
}


output id string = configurationStore.id
output name string = configurationStore.name
output logAnalyticsName string = logAnalyticsName
