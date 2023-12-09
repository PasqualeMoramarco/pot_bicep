@description('Resources Group location')
param location string

@description('Resources tags')
param tags object = {}

@description('Service Name, must be an unique string without spaces, max lenght is 255 characters')
@minLength(1)
@maxLength(63)
param redisCacheName string
param setDiagnosticSettings bool = true

param skuName string = 'Standard'
param skuFamily string = 'C'
param skuCapacity int = 1

param logAnalyticsName string
param diagnosticSettingsName string

resource logAnalytics 'microsoft.operationalinsights/workspaces@2021-12-01-preview' existing = {
  name: logAnalyticsName
}

resource redisCache 'Microsoft.Cache/Redis@2022-05-01' = {
  name: redisCacheName
  location: location
  tags: tags
  properties: {
    redisVersion: '6.0'
    sku: {
      name: skuName
      family: skuFamily
      capacity: skuCapacity
    }
    enableNonSslPort: false
    publicNetworkAccess: 'Enabled'
    redisConfiguration: {
      'maxmemory-reserved': '125'
      'maxfragmentationmemory-reserved': '125'
      'maxmemory-delta': '125'
    }
  }
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (setDiagnosticSettings) {
  name: diagnosticSettingsName
  scope: redisCache
  properties: {
    workspaceId: logAnalytics.id
    logs: [
      {
        categoryGroup: 'audit'
        enabled: true
      }
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true
        }
      }
    ]
  }
}
