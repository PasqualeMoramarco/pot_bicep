// * PARAMETERS

param cosmosDBAccountName string
param cosmosDB object

// * RESOURCES

resource cosmosDBAccount 'Microsoft.DocumentDB/databaseAccounts@2022-05-15' existing = {
  name: cosmosDBAccountName
}

resource cosmosDBResource 'Microsoft.DocumentDB/databaseAccounts/mongodbDatabases@2023-04-15' = {
  parent: cosmosDBAccount
  name: cosmosDB.name
  properties: {
    resource: {
      id: cosmosDB.name
    }
  }

  resource cosmosDBContainer 'collections' = [for item in cosmosDB.collections: {
    name: item.name
    properties: {
      resource: {
        id: item.name
        indexes: item.indexes
        shardKey: contains(item, 'shardKey') ? item.analyticalStorageTtl : {}
        analyticalStorageTtl: contains(item, 'analyticalStorageTtl') ? item.analyticalStorageTtl : []
      }
    }
  }]
}
