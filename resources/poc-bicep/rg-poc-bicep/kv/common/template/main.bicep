// * RESOURCE NAME
param resourceName string
var keyVaultName = '${resourceName}-${toLower(environment)}-${azLocation.outputs.code}'

// * PARAMS
param location string = resourceGroup().location

@description('Azure Environment')
param environment string

@description('Resources tags')
param tags object = {}

@description('Resources Access Policies')
param accessPolicies array = []

@description('Vault Secrets')
@secure()
param secrets object = {}

param logAnalyticsName string
param privateDnsZoneId string
param privateEndpointSubnetId string

// * VARS
var finalTags = union(resourceGroup().tags, tags)

var secretsFinal = union({
    'default--key': '00000000-1001-1001-8e82-000000000000'
  }, secrets)

// * RESOURCES
module azLocation '../../../../../../modules/azLocations.bicep' = {
  name: '${deployment().name}.location'
  params: {
    location: location
  }
}


module vaultModule '../../../../../../modules/vaults.bicep' = {
  name: '${deployment().name}.vaultModule'
  params: {
    location: azLocation.outputs.name
    tenantId: tenant().tenantId
    vaultName: keyVaultName
    tags: finalTags
    vaultUri: 'https://${keyVaultName}${az.environment().suffixes.keyvaultDns}'
    accessPolicies: accessPolicies
    logAnalyticsName: logAnalyticsName
    diagnosticSettingsName: 'SendToLAW'
    publicNetworkAccess: 'Disabled'
  }
}

module vaultSecretsModule '../../../../../../modules/vaultsSecrets.bicep' = {
  name: '${deployment().name}.vaultSecretsModule'
  params: {
    vaultName: vaultModule.outputs.vaultName
    secrets: secretsFinal
  }
}

module privateEndpoint '../../../../../../modules/privateEndpoint.bicep' = {
  name: '${deployment().name}.privateEndpoint'
  params: {
    tags: finalTags
    location: azLocation.outputs.name
    groupIds: 'vault'
    resourceID: vaultModule.outputs.vaultId
    privateEndpointName: '${vaultModule.outputs.vaultName}-pep'
    virtualNetworkSubnetId: privateEndpointSubnetId
    privateDnsZoneConfigs: {
      name: 'privatelink_vaultcore_azure_net'
      properties: {
        privateDnsZoneId: '${privateDnsZoneId}/privatelink.vaultcore.azure.net'
      }
    }
  }
}
