// * RESOURCE NAME
param resourceName string
var functionAppName = '${resourceName}-${toLower(environment)}-${azLocation.outputs.code}'

// * PARAMS
param location string = resourceGroup().location

@description('Azure Environment')
param environment string

@description('Resources tags')
param tags object = {}

param appServicePlanName string
param functionAppSettings array = []
param appInsightsName string

param javaVersion string

// * VARS
var finalTags = union(resourceGroup().tags, tags)

// * RESOURCES
module azLocation '../../../../../../modules/azLocations.bicep' = {
  name: '${deployment().name}.location'
  params: {
    location: location
  }
}

// Network settings
var aspNameSplitted = split(appServicePlanName, '-')
var serverPrefix = aspNameSplitted[1]
var serverfarm = aspNameSplitted[length(aspNameSplitted) - 1]
resource vnet 'Microsoft.Network/virtualNetworks@2022-07-01' existing = {
  name: 'PradaWE_VNet'
  scope: resourceGroup('PradaWE_RG')

  resource snet 'subnets' existing = {
    name: 'pg-${serverPrefix}-snet-plan-${toLower(environment)}-${azLocation.outputs.code}-${serverfarm}'
  }
}

module functionAppModule '../../../../../../modules/functionApps.bicep' = {
  name: '${deployment().name}.functionAppModule'
  params: {
    functionAppName: functionAppName
    location: azLocation.outputs.name
    tags: finalTags
    appServicePlanName: appServicePlanName
    functionAppSettings: functionAppSettings
    linuxFxVersion: 'JAVA|${javaVersion}'
    appInsightsName: appInsightsName
    // userAssignedIdentityName: 'pg-${serverPrefix}-id-functions-${toLower(environment)}'
    virtualNetworkSubnetId: vnet::snet.id
    contentShareEnable: false
    evhnMetricsEnabled: false
    evhnMetricsEnv: (toLower(environment) != 'prod' ? 'noprod' : 'prod')
    alwaysOn: true
  }
}
