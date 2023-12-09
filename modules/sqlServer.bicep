@description('Resources Group location')
param location string

param defenderEnabled bool

@description('Resources tags')
param tags object = {}

@description('Service Name, must be an unique string without spaces, max lenght is 255 characters')
@minLength(1)
@maxLength(63)
param sqlServerName string
param serverVersion string = '12.0'
@secure()
param sqlServerAdminUsername string
@secure()
param sqlServerAdminPassword string
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Disabled'
@allowed([
  'Enabled'
  'Disabled'
])
param restrictOutboundNetworkAccess string = 'Disabled'
param firewallExceptions array = []
param administrator object = {}

// Audit
param auditEnabled bool = false
param retentionDays int = 60
param auditStorageAccount string = 'none'
var storageEndpoint = 'https://${auditStorageAccount}.blob.${az.environment().suffixes.storage}/'

var administrators = union({
  administratorType: 'ActiveDirectory'
  principalType: 'Group'
  login: 'database-global-administrators'
  sid: '827b33ae-f661-4c17-8e3f-62d6591d95d0'
  tenantId: 'c31b26ba-a20c-4368-abc3-612adb51e20e'
}, administrator)

param storageAccountSubscriptionId string = '8055f06c-1c19-49e8-a3c9-9196d6f91c90'

resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: sqlServerName
  location: location
  tags: tags
  properties: {
    administratorLogin: sqlServerAdminUsername
    administratorLoginPassword: sqlServerAdminPassword
    version: serverVersion
    publicNetworkAccess: publicNetworkAccess
    administrators: administrators
    restrictOutboundNetworkAccess: restrictOutboundNetworkAccess
  }
}

resource firewallException 'Microsoft.Sql/servers/firewallRules@2022-05-01-preview' = [for ip in firewallExceptions: {
  parent: sqlServer
  name: ip.name
  properties: {
    endIpAddress: ip.address
    startIpAddress: ip.address
  }
}]

// resource lockResource 'Microsoft.Authorization/locks@2020-05-01' = { 
//   name: '${sqlServerName}-lock' 
//   scope: sqlServer 
//   properties:{ 
//     level: 'CanNotDelete' 
//     notes: 'Component managed by Bicep, and should not be deleted.' 
//   } 
// }

resource advancedThreatProtectionSettings 'Microsoft.Sql/servers/advancedThreatProtectionSettings@2022-08-01-preview' = if (defenderEnabled) {
  parent: sqlServer
  name: 'Default'
  properties: {
    state: 'Enabled'
  }
}

resource securityAlertPolicies 'Microsoft.Sql/servers/securityAlertPolicies@2022-08-01-preview' = if (defenderEnabled) {
  parent: sqlServer
  name: 'Default'
  properties: {
    state: 'Enabled'
    disabledAlerts: [
      ''
    ]
    emailAddresses: [
      ''
    ]
    emailAccountAdmins: false
    retentionDays: 0
  }
}

resource sqlVulnerabilityAssessments 'Microsoft.Sql/servers/sqlVulnerabilityAssessments@2022-08-01-preview' = if (defenderEnabled) {
  parent: sqlServer
  name: 'Default'
  properties: {
    state: 'Enabled'
  }
}

resource sqlServerAudit 'Microsoft.Sql/servers/auditingSettings@2022-11-01-preview' = if (auditEnabled) {
  parent: sqlServer
  name: 'default'
  properties: {
    retentionDays: retentionDays
    auditActionsAndGroups: [
      'SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP'
      'FAILED_DATABASE_AUTHENTICATION_GROUP'
      'BATCH_COMPLETED_GROUP'
    ]
    isAzureMonitorTargetEnabled: false
    isManagedIdentityInUse: true
    state: 'Enabled'
    storageEndpoint: storageEndpoint
    storageAccountSubscriptionId: storageAccountSubscriptionId
  }
}

output sqlServerId string = sqlServer.id
