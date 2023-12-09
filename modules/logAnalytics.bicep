@description('Resources Group location')
param location string

@description('Resources tags')
param tags object = {}

@description('Resources Name, must be an unique string without spaces')
@minLength(3)
@maxLength(24)
param logAnalyticsName string

param dataExports array = []

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsName
  location: location
  properties: {
    sku: {
      name: 'pergb2018'
    }
    retentionInDays: 30
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    workspaceCapping: {
      dailyQuotaGb: -1
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
  tags: tags
}

resource dataexportsResurce 'Microsoft.OperationalInsights/workspaces/dataExports@2020-08-01' = [for dataExport in dataExports: {
  parent: logAnalytics
  name: dataExport.eventHubName
  properties: {
    destination: {
      resourceId: dataExport.eventHubId
      metaData: {
        eventHubName: dataExport.eventHubName
      }
    }
    enable: dataExport.enable
    tableNames: dataExport.tableNames
  }
}]

// {
//   "type": "Microsoft.OperationalInsights/workspaces/dataexports",
//   "apiVersion": "2020-08-01",
//   "name": "[concat(parameters('workspaces_pg_bi_log_preprod_we_name'), '/pg-mt-evh-splunk-preprod-001')]",
//   "location": "westeurope",
//   "properties": {
//       "destination": {
//           "resourceId": "/subscriptions/57041f0e-8ca9-4590-b444-a6896059356f/resourceGroups/RG-Monitoring-Splunk-Integration-PREPROD/providers/Microsoft.EventHub/namespaces/splunk-preprod-eventhub",
//           "metaData": {
//               "eventHubName": "pg-mt-evh-splunk-preprod-001"
//           }
//       },
//       "tableNames": [
//           "FunctionAppLogs",
//           "AppTraces",
//           "AppRequests"
//       ],
//       "enable": true,
//   }
// },
