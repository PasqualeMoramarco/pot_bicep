@description('Resources Group location')
param location string

@description('Resources tags')
param tags object = {}

@description('Service Name, must be an unique string without spaces, max lenght is 255 characters')
@minLength(3)
@maxLength(63)
param dataFactoryName string

param logWorkSpaceId string


resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: dataFactoryName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  // kind: 'web'
  // properties: {
  //   Application_Type: 'web'
  //   Flow_Type: 'Redfield'
  //   Request_Source: 'IbizaAIExtension'
  //   RetentionInDays: 90
  //   WorkspaceResourceId: Workspace.id
  //   IngestionMode: 'LogAnalytics'
  //   publicNetworkAccessForIngestion: 'Enabled'
  //   publicNetworkAccessForQuery: 'Enabled'
  // }
  tags: tags
}

resource lockResource 'Microsoft.Authorization/locks@2020-05-01' = { 
  name: '${dataFactoryName}-lock' 
  scope: dataFactory 
  properties:{ 
    level: 'CanNotDelete' 
    notes: 'Component managed by Bicep, and should not be deleted.' 
  } 
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'SendToLAW'
  scope: dataFactory
  properties: {
    workspaceId: logWorkSpaceId
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
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
