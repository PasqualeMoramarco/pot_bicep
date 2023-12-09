@description('Resources Group location')
param location string

@description('Resources tags')
param tags object = {}

@description('Resource Name, must be an unique string without spaces, max lenght is 63 characters')
@minLength(1)
@maxLength(63)
param sqlElasticPoolName string

param sqlServerName string

param logAnalyticsName string

param skuName string = 'StandardPool'
param skuTier string = 'Standard'
param capacity int = 50
param minCapacity int = 0
param maxCapacity int = 50
param maxSizeBytes int = 53687091200
param zoneRedundant bool = false

resource maintenanceConfiguration 'Microsoft.Maintenance/publicMaintenanceConfigurations@2022-11-01-preview' existing = {
  name: 'SQL_Default'
  scope: subscription()
}

resource SqlElasticPool 'Microsoft.Sql/servers/elasticPools@2022-05-01-preview' = {
  name: '${sqlServerName}/${sqlElasticPoolName}'
  location: location
  tags: tags
  sku: {
    name: skuName
    tier: skuTier
    capacity: capacity
  }
  properties: {
    maxSizeBytes: maxSizeBytes
    perDatabaseSettings: {
      minCapacity: minCapacity
      maxCapacity: maxCapacity
    }
    zoneRedundant: zoneRedundant
    maintenanceConfigurationId: maintenanceConfiguration.id
  }
}

output test string = logAnalyticsName

// resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' existing = {
//   name: logAnalyticsName
// }

// resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
//   name: 'SendToLAW'
//   scope: SqlElasticPool
//   properties: {
//     workspaceId: logAnalytics.id
//     logs: []
//     metrics: [
//       {
//         category: 'Basic'
//         enabled: false
//         retentionPolicy: {
//           days: 30
//           enabled: true
//         }
//       }
//     ]
//   }
// }
