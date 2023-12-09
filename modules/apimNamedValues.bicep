/////////////////////////////////////
// PARAMETERS                      //
/////////////////////////////////////

param apiManagementName string
param namedValueName string
param namedValueDisplayName string
// @secure()
// param namedValueSecret string
// param namedValueTags string
param keyVaultName string
param secretName string

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
  // scope: resourceGroup('RG-BICEP-PLG-DEV')

  resource secret 'secrets' existing = {
    name: secretName
  }
}

resource apiManagement 'Microsoft.ApiManagement/service@2021-12-01-preview' existing =  {
  name: apiManagementName

  resource namedValuesResource 'namedValues@2021-12-01-preview' = {
    name: namedValueName
    properties: {
      displayName: namedValueDisplayName
      secret: true
      // value: namedValue.Value
      // tags: namedValueTags
      keyVault: {
        secretIdentifier: keyVault::secret.properties.secretUri
      }
    }
  }
}
