// * RESOURCE NAME
param resourceName string
var publicIpName = '${resourceName}-${toLower(environment)}-${azLocation.outputs.code}'

// * PARAMS
param location string = resourceGroup().location

@description('Azure Environment')
param environment string

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

module pipNgCommonModule '../../../../../../modules/publicIp.bicep' = {
  name: '${deployment().name}.pipNgCommonModule'
  params: {
    location: azLocation.outputs.name
    tags: finalTags
    publicIpName: publicIpName
  }
}
