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
param capacity int = 5
param tier string = 'Basic'
param name  string = 'Basic'

@description('Database max size in bytes')
param maxSizeBytes int = 2147483648


resource publicMaintenanceConfiguration 'Microsoft.Maintenance/publicMaintenanceConfigurations@2022-07-01-preview' existing = {
  name: 'SQL_Default'
  scope: subscription()
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2022-02-01-preview' = {
  name: '${sqlServerName}/${sqlDatabaseName}'
  location: location
  tags: tags
  sku: {
    name: name
    tier: tier
    capacity: capacity
  }
  // kind: 'v12.0,user'
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: maxSizeBytes
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
    zoneRedundant: false
    readScale: 'Disabled'
    requestedBackupStorageRedundancy: 'Local'
    maintenanceConfigurationId: publicMaintenanceConfiguration.id
    isLedgerOn: false
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

resource lockResource 'Microsoft.Authorization/locks@2020-05-01' = { 
  name: '${sqlServerName}-lock' 
  scope: sqlDatabase 
  properties:{ 
    level: 'CanNotDelete' 
    notes: 'Component managed by Bicep, and should not be deleted.' 
  } 
}
