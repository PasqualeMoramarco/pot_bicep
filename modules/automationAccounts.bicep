param automationAccountsName string
param type string = 'SystemAssigned'
param sku string = 'Basic'

@description('Resources Group location')
param location string

@description('Resources tags')
param tags object = {}


resource automationAccounts 'Microsoft.Automation/automationAccounts@2022-08-08' = {
  name: automationAccountsName
  tags: tags
  location: location
  identity: {
    type: type
  }
  properties: {
    publicNetworkAccess: true
    disableLocalAuth: false
    sku: {
      name: sku
    }
    encryption: {
      keySource: 'Microsoft.Automation'
      identity: {}
    }
  }
}

resource automationAccounts_connectionTypes_name 'Microsoft.Automation/automationAccounts/connectionTypes@2022-08-08' = {
  parent: automationAccounts
  name: 'Azure'
  properties: {
    isGlobal: true
    fieldDefinitions: {
      AutomationCertificateName: {
        isEncrypted: false
        isOptional: false
        type: 'System.String'
      }
      SubscriptionID: {
        isEncrypted: false
        isOptional: false
        type: 'System.String'
      }
    }
  }
}

resource automationAccountconnectionTypes_AzureClassicCertificate 'Microsoft.Automation/automationAccounts/connectionTypes@2022-08-08' = {
  parent: automationAccounts
  name: 'AzureClassicCertificate'
  properties: {
    isGlobal: true
    fieldDefinitions: {
      SubscriptionName: {
        isEncrypted: false
        isOptional: false
        type: 'System.String'
      }
      SubscriptionId: {
        isEncrypted: false
        isOptional: false
        type: 'System.String'
      }
      CertificateAssetName: {
        isEncrypted: false
        isOptional: false
        type: 'System.String'
      }
    }
  }
}

resource automationAccountconnectionTypes_AzureServicePrincipal 'Microsoft.Automation/automationAccounts/connectionTypes@2022-08-08' = {
  parent: automationAccounts
  name: 'AzureServicePrincipal'
  properties: {
    isGlobal: true
    fieldDefinitions: {
      ApplicationId: {
        isEncrypted: false
        isOptional: false
        type: 'System.String'
      }
      TenantId: {
        isEncrypted: false
        isOptional: false
        type: 'System.String'
      }
      CertificateThumbprint: {
        isEncrypted: false
        isOptional: false
        type: 'System.String'
      }
      SubscriptionId: {
        isEncrypted: false
        isOptional: false
        type: 'System.String'
      }
    }
  }
}
