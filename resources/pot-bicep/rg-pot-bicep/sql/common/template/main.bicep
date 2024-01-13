// * RESOURCE NAME
param resourceName string
var sqlServerName = '${resourceName}-${toLower(environment)}-${azLocation.outputs.code}'

// * PARAMS
param location string = resourceGroup().location

@description('Azure Environment')
param environment string

@description('Resources tags')
param tags object = {}

param privateEndpointSubnetId string = ''
param privateDnsZoneId string = ''
param firewallExceptions array = []

// * VARS
var finalTags = union(resourceGroup().tags, tags)

// * RESOURCES
module azLocation '../../../../../../modules/azLocations.bicep' = {
  name: '${deployment().name}.location'
  params: {
    location: location
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: 'brg-pot-kv-${toLower(environment)}-we'
}

module sqlServerModule '../../../../../../modules/sqlServer.bicep' = {
  name: '${deployment().name}.sqlServerModule'
  params: {
    sqlServerName: sqlServerName
    location: azLocation.outputs.name
    tags: finalTags
    sqlServerAdminUsername: keyVault.getSecret('${sqlServerName}--sqlServerAdminUsername')
    sqlServerAdminPassword: keyVault.getSecret('${sqlServerName}--sqlServerAdminPassword')
    firewallExceptions: firewallExceptions
    defenderEnabled: (toLower(environment) == 'prod' ? true : false)
    publicNetworkAccess: 'Enabled'
  }
}

module privateEndpoint '../../../../../../modules/privateEndpoint.bicep' = if(privateEndpointSubnetId != '') {
  name: '${deployment().name}.privateEndpoint'
  params: {
    tags: finalTags
    location: azLocation.outputs.name
    groupIds: 'sqlServer'
    resourceID: sqlServerModule.outputs.sqlServerId
    privateEndpointName: '${sqlServerName}-pep'
    virtualNetworkSubnetId: privateEndpointSubnetId
    privateDnsZoneConfigs: {
      name: 'privatelink_database_windows_net'
      properties: {
        privateDnsZoneId: '${privateDnsZoneId}/privatelink${az.environment().suffixes.sqlServerHostname}'
      }
    }
  }
}
