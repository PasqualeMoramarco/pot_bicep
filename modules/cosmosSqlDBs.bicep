// * PARAMETERS

param cosmosDBAccountName string
param cosmosDB object

// * RESOURCES

resource cosmosDBAccount 'Microsoft.DocumentDB/databaseAccounts@2022-05-15' existing = {
  name: cosmosDBAccountName
}

resource cosmosDBResource 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2022-05-15' = {
  parent: cosmosDBAccount
  name: cosmosDB.name
  properties: {
    resource: {
      id: cosmosDB.name
    }
  }

  resource cosmosDBContainer 'containers' = [for item in items(cosmosDB.containers): {
    name: item.key
    properties: {
      resource: {
        id: item.key
        indexingPolicy: {
          indexingMode: (contains(item.value, 'indexingMode') ? item.value.indexingMode : 'consistent')
          automatic: true
          includedPaths: [
            {
              path: '/*'
            }
          ]
          excludedPaths: [
            {
              path: '/"_etag"/?'
            }
          ]
        }
        partitionKey: {
          paths: [
            (contains(item.value, 'partitionKey') ? item.value.partitionKey.path : '/id')
          ]
          kind: (contains(item.value, 'partitionKey') ? item.value.partitionKey.kind : 'Hash')
        }
        defaultTtl: -1
        uniqueKeyPolicy: {
          uniqueKeys: []
        }
        conflictResolutionPolicy: {
          mode: 'LastWriterWins'
          conflictResolutionPath: '/_ts'
        }
      }
    }
  }]
}
