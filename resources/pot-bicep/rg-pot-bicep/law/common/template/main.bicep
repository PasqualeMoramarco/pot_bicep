// * RESOURCE NAME
param resourceName string
var logAnalyticsName = '${resourceName}-${toLower(environment)}-${azLocation.outputs.code}'

// * PARAMS
param location string = resourceGroup().location

@description('Azure Environment')
param environment string

@description('Resources tags')
param tags object = {}

@description('Splunk Data Export')
param dataExports array = []

var finalTags = union(resourceGroup().tags, tags)


// * RESOURCES
module azLocation '../../../../../../modules/azLocations.bicep' = {
  name: '${deployment().name}.location'
  params: {
    location: location
  }
}

module logAnalyticsModule '../../../../../../modules/logAnalytics.bicep' = {
  name: '${deployment().name}.logAnalyticsModule'
  params: {
    location: azLocation.outputs.name
    tags: finalTags
    logAnalyticsName: logAnalyticsName
    dataExports: dataExports
  }
}


