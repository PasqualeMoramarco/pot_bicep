// * PARAMETERS

param location string
param cosmosDBAccountName string

@description('Resources tags')
param tags object = {}

param ipRules array = []

// GESTIONE LOG ANALYTICS
param logAnalyticsName string
resource Workspace 'microsoft.operationalinsights/workspaces@2021-12-01-preview' existing = {
  name: logAnalyticsName
}

// * RESOURCES

resource cosmosDBAccount 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' = {
  name: cosmosDBAccountName
  location: location
  tags: tags
  kind: 'MongoDB'
  identity: {
    type: 'None'
  }
  properties: {
    databaseAccountOfferType: 'Standard'
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    backupPolicy: {
      type: 'Periodic'
      periodicModeProperties: {
        backupIntervalInMinutes: 240
        backupRetentionIntervalInHours: 8
        backupStorageRedundancy: 'Local'
      }
    }
    isVirtualNetworkFilterEnabled: false
    virtualNetworkRules: []
    ipRules: ipRules
    minimalTlsVersion: 'Tls12'
    capabilities: [
      {
        name: 'EnableMongo'
      }
      {
        name: 'DisableRateLimitingResponses'
      }
      {
        name: 'EnableServerless'
      }
    ]
    apiProperties: {
      serverVersion: '4.2'
    }
    enableFreeTier: false
    capacity: {
      totalThroughputLimit: 4000
    }
    defaultIdentity: 'FirstPartyIdentity'
    analyticalStorageConfiguration: {
      schemaType: 'FullFidelity'
    }
  }
}

resource lockResource 'Microsoft.Authorization/locks@2020-05-01' = {
  name: '${cosmosDBAccountName}-lock'
  scope: cosmosDBAccount
  properties: {
    level: 'CanNotDelete'
    notes: 'Component managed by Bicep, and should not be deleted.'
  }
}

// GESTIONE DIAGNOSTIC SETTINGS
param diagnosticSettingsName string = 'SendToLAW'
resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: diagnosticSettingsName
  scope: cosmosDBAccount
  properties: {
    workspaceId: Workspace.id
    logs: [
      {
        category: 'DataPlaneRequests'
        enabled: true
      }
      {
        category: 'QueryRuntimeStatistics'
        enabled: true
      }
      {
        category: 'PartitionKeyStatistics'
        enabled: true
      }
      {
        category: 'PartitionKeyRUConsumption'
        enabled: true
      }
      {
        category: 'ControlPlaneRequests'
        enabled: false
      }
      {
        category: 'TableApiRequests'
        enabled: false
      }
      {
        category: 'MongoRequests'
        enabled: true
      }
      {
        category: 'CassandraRequests'
        enabled: false
      }
      {
        category: 'GremlinRequests'
        enabled: false
      }
    ]
    metrics: [
      {
        category: 'Requests'
        enabled: true
        // retentionPolicy: {
        //   days: 30
        //   enabled: true
        // }
      }
    ]
  }
}

// // GESTIONE BUILT-IN ROLES
// resource CosmosDB_databaseAccount_DataReader_BuiltInRole 'Microsoft.DocumentDB/databaseAccounts/mongodbRoleDefinitions@2023-04-15' = {
//   parent: cosmosDBAccount
//   name: '00000000-0000-0000-0000-000000000001'
//   properties: {
//     roleName: 'Cosmos DB Built-in Data Reader'
//     type: 'BuiltInRole'
//     databaseName: cosmosDBAccount.name
//     permissions: [
//       {
//         dataActions: [
//           'Microsoft.DocumentDB/databaseAccounts/readMetadata'
//           'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/executeQuery'
//           'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/readChangeFeed'
//           'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/read'
//         ]
//         notDataActions: []
//       }
//     ]
//   }
// }

// resource CosmosDB_databaseAccount_DataContributor_BuiltInRole 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2022-05-15' = {
//   parent: cosmosDBAccount
//   name: '00000000-0000-0000-0000-000000000002'
//   properties: {
//     roleName: 'Cosmos DB Built-in Data Contributor'
//     type: 'BuiltInRole'
//     assignableScopes: [
//       cosmosDBAccount.id
//     ]
//     permissions: [
//       {
//         dataActions: [
//           'Microsoft.DocumentDB/databaseAccounts/readMetadata'
//           'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/*'
//           'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/*'
//         ]
//         notDataActions: []
//       }
//     ]
//   }
// }

output cosmosAccountID string = cosmosDBAccount.id
