// * RESOURCE NAME

param resourceName string


// * PARAMS
param location string = resourceGroup().location

param appInsightsName string

@description('The managed resource group Id.')
param managedResourceGroupId string

param storageAccountSkuName string
param storageAccountName string
// param vnetAddressPrefix string
// param authorizations array

@description('Resources tags')
param tags object = {}

@description('The pricing tier of workspace.')
@allowed([
  'standard'
  'premium'
])
param pricingTier string = 'premium'

resource databrick 'Microsoft.Databricks/workspaces@2022-04-01-preview' = {
  name: resourceName
  location: location
  tags: tags
  sku: {
    name: pricingTier
  }
  properties: {
    managedResourceGroupId: managedResourceGroupId
    parameters: {
      enableNoPublicIp: {
        value: false
      }
      storageAccountName: {
        value: storageAccountName
      }
      storageAccountSkuName: {
        value: storageAccountSkuName
      }
      // vnetAddressPrefix: {
      //   value: vnetAddressPrefix
      // }
    }
    // authorizations: authorizations
  }
}

resource appInsights 'microsoft.insights/components@2020-02-02' existing = {
  name: appInsightsName
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'SendToLAW'
  scope: databrick
  properties: {
    workspaceId: appInsights.properties.WorkspaceResourceId
    logs: [
      {
        category: 'workspace'
        enabled: true
      }
      {
        category: 'accounts'
        enabled: true
      }
    ]
  }
}
