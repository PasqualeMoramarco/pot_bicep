@description('Resources Group location')
param location string

@description('Resources tags')
param tags object = {}

@description('Service Name, must be an unique string without spaces, max lenght is 255 characters')
@minLength(1)
@maxLength(255)
param appInsightsName string

param logAnalyticsName string

resource Workspace 'microsoft.operationalinsights/workspaces@2021-12-01-preview' existing = {
  name: logAnalyticsName
}

resource appInsights 'microsoft.insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Redfield'
    Request_Source: 'IbizaAIExtension'
    RetentionInDays: 90
    WorkspaceResourceId: Workspace.id
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
  tags: tags
}
