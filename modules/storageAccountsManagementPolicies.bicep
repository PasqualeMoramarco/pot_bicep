@description('Resources Name, most be an unique string without spaces')
@minLength(3)
@maxLength(24)
param storageAccountName string

param rules array = []

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: storageAccountName

  resource managementPolicie 'managementPolicies' = {
    name: 'default'
    properties: {
      policy: {
        rules: rules
      }
    }

  }
}
