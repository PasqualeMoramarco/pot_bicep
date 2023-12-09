@description('Resources Group location')
param location string

param defenderEnabled bool

@description('Resources tags')
param tags object = {}

@description('Service Name, must be an unique string without spaces, max lenght is 255 characters')
@minLength(1)
@maxLength(150)
param sqlDatabaseName string
param sqlServerName string
param sqlElasticPoolName string
@allowed([
  'Enabled'
  'Disabled'
])
param readScale string = 'Disabled'
@allowed([
  // 'Copy'
  'Default'
  'OnlineSecondary'
  // 'PointInTimeRestore'
  // 'Recovery'
  // 'Restore'
  // 'RestoreExternalBackup'
  // 'RestoreExternalBackupSecondary'
  // 'RestoreLongTermRetentionBackup'
  // 'Secondary'
])
param createMode string = 'Default'
@description('Required when "creationMode" is equalts to "OnlineSecondary"')
param sourceDatabaseId string = ''
@description('Bound with ElasticPool Sku')
param skuTier string = 'Standard'
@description('Required when "creationMode" is equalts to "OnlineSecondary"')
param secondaryType string = ''

@description('Database max size in bytes')
param maxSizeBytes int = 2147483648

resource publicMaintenanceConfiguration 'Microsoft.Maintenance/publicMaintenanceConfigurations@2022-11-01-preview' existing = {
  name: 'SQL_Default'
  scope: subscription()
}

resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' existing = {
  name: sqlServerName

  resource SqlElasticPool 'elasticPools@2022-05-01-preview' existing = {
    name: sqlElasticPoolName
  }
}

// param servers_pg_mw_sql_qfe_we_externalid string = '/subscriptions/8055f06c-1c19-49e8-a3c9-9196d6f91c90/resourceGroups/rg-middleware-qfe/providers/Microsoft.Sql/servers/pg-mw-sql-qfe-we'

resource sqlDatabase 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  parent: sqlServer
  name: sqlDatabaseName
  location: location
  tags: tags
  sku: (sourceDatabaseId == '' ? {
    name: 'ElasticPool'
    tier: skuTier
    capacity: 0
  } : null)
  // kind: 'v12.0,user'
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: maxSizeBytes
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
    elasticPoolId: sqlServer::SqlElasticPool.id
    zoneRedundant: false
    readScale: readScale
    requestedBackupStorageRedundancy: 'Local'
    maintenanceConfigurationId: publicMaintenanceConfiguration.id
    isLedgerOn: false
    createMode: createMode
    sourceDatabaseId: (sourceDatabaseId != '' ? sourceDatabaseId : null)
    secondaryType: (secondaryType != '' ? secondaryType : null)
  }
}

resource vulnerabilityAssessments 'Microsoft.Sql/servers/databases/vulnerabilityAssessments@2022-08-01-preview' = if (defenderEnabled) {
  parent: sqlDatabase
  name: 'Default'
  properties: {
    recurringScans: {
      isEnabled: false
      emailSubscriptionAdmins: true
      emails: []
    }
  }
}

resource databasesVulnerabilityAssessments 'Microsoft.Sql/servers/databases/vulnerabilityAssessments@2022-08-01-preview' = if (defenderEnabled) {
  name: '${sqlServerName}/master/Default'
  properties: {
    recurringScans: {
      isEnabled: false
      emailSubscriptionAdmins: true
      emails: []
    }
  }
}

output databaseId string = sqlDatabase.id
