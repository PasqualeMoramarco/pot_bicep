param automationAccountsName string = 'pg-dm365-aa-cross-we'



resource automationAccounts 'Microsoft.Automation/automationAccounts@2022-08-08' existing = {
  name: automationAccountsName
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
