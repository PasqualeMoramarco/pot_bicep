@description('Resources Name, most be an unique string, start with letter. End with letter or digit. Can not contain consecutive hyphens.')
@minLength(3)
@maxLength(24)
param vaultName string

@description('Enabled Attributes')
param attributesEnabled bool = true

@description('Vault Secrets')
@secure()
param secrets object = {}

resource vaultsResources 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: vaultName

  resource vaultSecret 'secrets' = [for secret in items(secrets): {
    name: secret.key
    properties: {
      attributes: {
        enabled: attributesEnabled
      }
      contentType: 'string'
      value: secret.value
    }
  }]
}
