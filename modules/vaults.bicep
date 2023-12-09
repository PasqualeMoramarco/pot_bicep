@description('Resources Group locations')
param location string

@description('Resources tags')
param tags object = {}

@description('Resources Name, most be an unique string, start with letter. End with letter or digit. Can not contain consecutive hyphens.')
@minLength(3)
@maxLength(24)
param vaultName string

@description('The Azure Active Directory tenant ID')
@minLength(36)
@maxLength(36)
param tenantId string

@allowed([
  'standard'
  'premium'
])
@description('Resources Sku Type')
param skuType string = 'standard'

@description('Resources Access Policies')
param accessPolicies array = []

@description('Specify the Retention of the soft purge in days')
param softDeleteRetentionInDays int = 90

@description('Specify the vault uri')
param vaultUri string

@allowed([
  'Disabled'
  'Enabled'
])
@description('Resources access from the public Network')
param publicNetworkAccess string = 'Disabled'

@description('Resources networkAcls ip rules')
param networkAclsIpRules array = []

@description('Resources networkAcls default action')
@allowed([
  'Allow'
  'Deny'
])
param networkAclsDefaultAction string = 'Deny'
param virtualNetworkRules array = []

@allowed([
  'RegisteringDns'
  'Succeeded'
])
@description('Provisioning state of the vault.')
param provisioningState string = 'Succeeded'

param logAnalyticsName string = ''
param diagnosticSettingsName string = 'SendToLAW'
param diagnosticLogs array = [
  {
    categoryGroup:'audit'
    enabled: true
  }
]

param enableRbacAuthorization bool = false


resource vaults 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: vaultName
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: skuType
    }
    tenantId: tenantId
    accessPolicies: accessPolicies
    enabledForDeployment: true
    enabledForDiskEncryption: true
    enabledForTemplateDeployment: true
    enableSoftDelete: true
    softDeleteRetentionInDays: softDeleteRetentionInDays
    enableRbacAuthorization: enableRbacAuthorization
    vaultUri: vaultUri
    publicNetworkAccess: publicNetworkAccess
    provisioningState: provisioningState
    enablePurgeProtection: true
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: virtualNetworkRules
      ipRules: networkAclsIpRules
      defaultAction: networkAclsDefaultAction
    }
  }
}

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = if (!empty(logAnalyticsName )) {
  name: logAnalyticsName
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsName)) {
  name: diagnosticSettingsName
  scope: vaults
  properties: {
    workspaceId: logAnalytics.id
    logs: diagnosticLogs
    metrics: []
    logAnalyticsDestinationType: 'AzureDiagnostics'
  }
}

output vaultId string = vaults.id
output vaultName string = vaults.name
