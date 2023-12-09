@description('Resources Group locations')
param location string

@description('Resources tags')
param tags object = {}

@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_ZRS'
  'Premium_LRS'
])
@description('Resources Sku Type')
param skuType string = 'Standard_LRS'

@allowed([
  'StorageV2'
])
@description('Resources Sku Kind')
param storageAccountKind string = 'StorageV2'

@description('Resources Name, most be an unique string without spaces')
@minLength(3)
@maxLength(24)
param storageAccountName string

@allowed([
  'Disabled'
  'Enabled'
])
@description('Resources access from the public Network')
param publicNetworkAccess string

@description('Resources Blob component access from the public Network')
param allowBlobPublicAccess bool = false

@description('Resources Blob component Encryption')
param encryption object = {
  requireInfrastructureEncryption: true
  keySource: 'Microsoft.Storage'
}

@description('Resources networkAcls ip rules')
param networkAclsIpRules array = []

@description('Resources networkAcls default action')
@allowed([
  'Allow'
  'Deny'
])
param networkAclsDefaultAction string = 'Deny'

@description('Resources resourceAccess rules')
param resourceAccessRules array = []

@allowed([
  'Cool'
  'Hot'
  'Premium'
])
@description('Resources accessTier type')
param accessTier string = 'Hot'

param containersList array = []
param shareList array = []
param tableList array = []
param queueList array = []
param virtualNetworkRules array = []

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  tags: tags
  sku: {
    name: skuType
  }
  kind: storageAccountKind
  properties: {
    defaultToOAuthAuthentication: false
    publicNetworkAccess: publicNetworkAccess
    allowCrossTenantReplication: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: allowBlobPublicAccess
    allowSharedKeyAccess: true
    isHnsEnabled: true
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: virtualNetworkRules
      ipRules: networkAclsIpRules
      defaultAction: networkAclsDefaultAction
      resourceAccessRules: resourceAccessRules
    }
    supportsHttpsTrafficOnly: true
    encryption: encryption
    accessTier: accessTier
  }
}

// resource lockResource 'Microsoft.Authorization/locks@2020-05-01' = { 
//   name: '${storageAccountName}-lock' 
//   scope: storageAccount 
//   properties:{ 
//     level: 'CanNotDelete' 
//     notes: 'Component managed by Bicep, and should not be deleted.' 
//   } 
// }

resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2022-09-01' = { // if (!empty(containersList)) {
  parent: storageAccount
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      allowPermanentDelete: false
      enabled: false
    }
  }

  resource blobServiceContainer 'containers' = [for container in containersList: {
    name: container
    properties: {
      // immutableStorageWithVersioning: {
      //   enabled: false
      // }
      defaultEncryptionScope: '$account-encryption-key'
      denyEncryptionScopeOverride: false
      publicAccess: 'None'
    }
  }]
}

resource fileServices 'Microsoft.Storage/storageAccounts/fileServices@2022-09-01' = if (!empty(shareList)) {
  parent: storageAccount
  name: 'default'
  // sku: {
  //   name: 'Standard_LRS'
  //   tier: 'Standard'
  // }
  // properties: {
  //   protocolSettings: {
  //     smb: {
  //     }
  //   }
  //   cors: {
  //     corsRules: []
  //   }
  //   shareDeleteRetentionPolicy: {
  //     enabled: true
  //     days: 7
  //   }
  // }
  resource fileServicesShare 'shares' = [for share in shareList: {
    name: share.name
    properties: {
      accessTier: 'TransactionOptimized'
      shareQuota: (share.quota != '' ? share.quota : null)
      enabledProtocols: 'SMB'
    }
  }]
}

resource queueServices 'Microsoft.Storage/storageAccounts/queueServices@2022-09-01' = if (!empty(queueList)) {
  parent: storageAccount
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }

  resource queueService 'queues' = [for queue in queueList: {
    name: queue
    properties: {}
  }]
}

resource tableServices 'Microsoft.Storage/storageAccounts/tableServices@2022-09-01' = if (!empty(tableList)) {
  parent: storageAccount
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }

  resource tableServiceTable 'tables' = [for table in tableList: {
    name: table
    properties: {
      signedIdentifiers: [
        {
          id: guid(storageAccount.name, 'tables', table, 'r')
          accessPolicy: {
            permission: 'r'
          }
        }
        {
          id: guid(storageAccount.name, 'tables', table, 'a')
          accessPolicy: {
            permission: 'a'
          }
        }
        {
          id: guid(storageAccount.name, 'tables', table, 'u')
          accessPolicy: {
            permission: 'u'
          }
        }
        {
          id: guid(storageAccount.name, 'tables', table, 'd')
          accessPolicy: {
            permission: 'd'
          }
        }
      ]
    }
  }]
}

output storageId string = storageAccount.id
