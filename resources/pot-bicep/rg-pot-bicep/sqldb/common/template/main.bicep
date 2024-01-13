// * RESOURCE NAME
param resourceName string
var sqlDatabaseName = '${resourceName}-${toLower(environment)}'


// * PARAMS
param location string = resourceGroup().location
param sqlServerName string

@description('Azure Environment')
param environment string

param sqldbtier string
param sqldbtiername string
param sqldbcapacity int

@description('Resources tags')
param tags object = {}

// 100 GB
param maxSizeBytes int = 107374182400

// * VARS
var finalTags = union(resourceGroup().tags, tags)

// * RESOURCES
module azLocation '../../../../../../modules/azLocations.bicep' = {
  name: '${deployment().name}.location'
  params: {
    location: location
  }
}

module sqlDatabaseModule '../../../../../../modules/sqlDatabase.bicep' = {
  name: '${deployment().name}.sqlDatabaseModule'
  params: {
    location: azLocation.outputs.name
    tags: finalTags
    sqlDatabaseName: sqlDatabaseName
    sqlServerName: sqlServerName
    maxSizeBytes: maxSizeBytes
    tier:sqldbtier
    name:sqldbtiername
    capacity: sqldbcapacity
    defenderEnabled: (toLower(environment) == 'prod' ? true : false)
  }
}
