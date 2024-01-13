// * RESOURCE NAME
param resourceName string
var appInsightsName = '${resourceName}-${toLower(environment)}-${azLocation.outputs.code}'

// * PARAMS
param location string = resourceGroup().location

@description('Azure Environment')
param environment string

param logAnalyticsName string

@description('Resources tags')
param tags object = {}

// * VARS
var finalTags = union(resourceGroup().tags, tags)

// * RESOURCES
module azLocation '../../../../../../modules/azLocations.bicep' = {
  name: '${deployment().name}.location'
  params: {
    location: location
  }
}


module appInsightsModule '../../../../../../modules/appInsights.bicep' = {
  name: '${deployment().name}.appInsightsModule'
  params: {
    location: azLocation.outputs.name
    tags: finalTags
    appInsightsName: appInsightsName
    logAnalyticsName: logAnalyticsName
  }
}