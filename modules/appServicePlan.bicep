@description('Resources Group location')
param location string

@description('Resources tags')
param tags object = {}

@description('Resource Name, must be an unique string without spaces, max lenght is 40 characters')
@minLength(1)
@maxLength(40)
param appServicePlanName string

param Sku string
@allowed([
  'ElasticPremium'
  'Basic'
])
param skuTier string = 'ElasticPremium'
param Kind string
param elasticScaleEnabled bool
param diagnosticSettingsName string = 'SendToLAW'
param setDiagnosticSettings bool = true
param maximumElasticWorkerCount int
param logAnalyticsName string
param reserved bool = false
param capacity int = 1

resource ApplicationServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  tags: tags
  sku: {
    name: Sku
    tier: skuTier
    capacity: capacity
    // skuCapacity: {
    //   minimum: 5
    // }
  }
  kind: Kind
  properties: {
    perSiteScaling: false
    elasticScaleEnabled: elasticScaleEnabled
    maximumElasticWorkerCount: (maximumElasticWorkerCount > 0 ? maximumElasticWorkerCount : null)
    isSpot: false
    reserved: reserved
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
    zoneRedundant: false
  }
}

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' existing = {
  name: logAnalyticsName
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (setDiagnosticSettings) {
  name: diagnosticSettingsName
  scope: ApplicationServicePlan
  properties: {
    workspaceId: logAnalytics.id
    logs: []
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        // retentionPolicy: {
        //   days: 30
        //   enabled: true
        // }
      }
    ]
  }
}
