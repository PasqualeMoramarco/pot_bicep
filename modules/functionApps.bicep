@description('Resources Group location')
param location string

@description('Resources tags')
param tags object = {}

@description('Resources Name, must be an unique string without spaces')
@minLength(2)
@maxLength(60)
param functionAppName string
param appServicePlanName string
param functionAppSettings array = []
param functionAppConnectionString array = []
param userAssignedIdentityName string = ''
@description('Default Plan subnet id')
param virtualNetworkSubnetId string = ''
param slotStagingEnabled bool = false
param javaVersion string = ''
param linuxFxVersion string = ''
param kind string = 'functionapp'
param appInsightsName string
param contentShareEnable bool = true

param evhnMetricsEnabled bool = false
param evhnMetricsEnv string = ''

param alwaysOn bool = false

param healthCheckEnable bool = false
param healthCheckPath string = '/api/liveness'

resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = if (userAssignedIdentityName != '') {
  name: userAssignedIdentityName
}

resource appInsights 'microsoft.insights/components@2020-02-02' existing = {
  name: appInsightsName
}

var appSettingsObject = reduce(functionAppSettings, {}, (cur, next) => union(cur, {
      '${next.name}': next.value
    }
  )
)

var functionNamePieces = split(functionAppName, '-')
var leftFunctionName = skip(functionNamePieces, 3)
var cleanFunctionNameArray = take(leftFunctionName, length(leftFunctionName) - 2)
var cleanFunctionName = join(cleanFunctionNameArray, '-')
var cleanFunctionNameWithNoSeparators = join(cleanFunctionNameArray, '')

var csSettings = (contentShareEnable ? {
  WEBSITE_CONTENTSHARE: cleanFunctionName
  WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: appSettingsObject.AzureWebJobsStorage
  WEBSITE_CONTENTOVERVNET: 1
} : {})

var mainSettings = { 
  AzureFunctionsWebHost__hostid: cleanFunctionName 
  DurableTaskHub: cleanFunctionNameWithNoSeparators
}

// o.O AZURE_CLIENT_ID: https://github.com/Azure/azure-sdk-for-net/issues/32786#issuecomment-1386592704
var appSettingsTemp = union(appSettingsObject, csSettings, {
    APPINSIGHTS_INSTRUMENTATIONKEY: appInsights.properties.InstrumentationKey
    APPLICATIONINSIGHTS_CONNECTION_STRING: appInsights.properties.ConnectionString
    WEBSITE_RUN_FROM_PACKAGE: 1
  }, (userAssignedIdentityName != '' ? {
    AZURE_CLIENT_ID: userAssignedIdentity.properties.clientId
  } : {})
)

var appSettingsSlot = union(appSettingsTemp,
  {
    WEBSITE_CONTENTSHARE: '${cleanFunctionName}-staging'
    AzureFunctionsWebHost__hostid: '${cleanFunctionName}-staging'
    DurableTaskHub: '${cleanFunctionNameWithNoSeparators}staging'
  }
)

var appSettings = union(appSettingsTemp, mainSettings)

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' existing = {
  name: appServicePlanName
}

resource functionAppSite 'Microsoft.Web/sites@2022-03-01' = {
  tags: tags
  name: functionAppName
  location: location
  kind: 'functionapp'
  identity: (userAssignedIdentityName != '' ? {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentity.id}': {}
    }
  } : {
    type: 'SystemAssigned'
  })
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: '${functionAppName}.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${functionAppName}.scm.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: appServicePlan.id
    reserved: false
    isXenon: false
    hyperV: false
    vnetRouteAllEnabled: (virtualNetworkSubnetId != '' ? true : false)
    vnetImagePullEnabled: false
    vnetContentShareEnabled: false
    siteConfig: {
      numberOfWorkers: 1
      acrUseManagedIdentityCreds: false
      alwaysOn: alwaysOn
      http20Enabled: true
      functionAppScaleLimit: 10
      minimumElasticInstanceCount: 1
      connectionStrings: [for connectionString in functionAppConnectionString: {
        name: connectionString.name
        connectionString: connectionString.value
        type: connectionString.type
      }]
      healthCheckPath: (healthCheckEnable ? healthCheckPath : null )
    }
    scmSiteAlsoStopped: false
    clientAffinityEnabled: false
    clientCertEnabled: false
    clientCertMode: 'Required'
    hostNamesDisabled: false
    // customDomainVerificationId: '8FFE04AB5CDD5885DA7907BBB36EC1988F280F28FC2C07C526888B653DAB846B'
    containerSize: 1536
    dailyMemoryTimeQuota: 0
    httpsOnly: true
    redundancyMode: 'None'
    storageAccountRequired: false
    virtualNetworkSubnetId: (virtualNetworkSubnetId != '' ? virtualNetworkSubnetId : null)
    keyVaultReferenceIdentity: (userAssignedIdentityName != '' ? userAssignedIdentity.id : null)
  }
}

resource functionAppSiteFtp 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-03-01' = {
  parent: functionAppSite
  name: 'ftp'
  #disable-next-line BCP187
  location: location
  properties: {
    allow: true
  }
}

resource functionAppSiteScm 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-03-01' = {
  parent: functionAppSite
  name: 'scm'
  #disable-next-line BCP187
  location: location
  properties: {
    allow: true
  }
}

resource functionAppSiteWeb 'Microsoft.Web/sites/config@2022-03-01' = {
  parent: functionAppSite
  name: 'web'
  properties: {
    numberOfWorkers: 1
    defaultDocuments: [
      'Default.htm'
      'Default.html'
      'Default.asp'
      'index.htm'
      'index.html'
      'iisstart.htm'
      'default.aspx'
      'index.php'
    ]
    netFrameworkVersion: 'v6.0'
    javaVersion: (javaVersion != '' ? javaVersion : null)
    linuxFxVersion: (linuxFxVersion != '' ? linuxFxVersion : null)
    requestTracingEnabled: false
    remoteDebuggingEnabled: false
    remoteDebuggingVersion: 'VS2019'
    httpLoggingEnabled: false
    acrUseManagedIdentityCreds: false
    logsDirectorySizeLimit: 35
    detailedErrorLoggingEnabled: false
    publishingUsername: '$${functionAppName}'
    scmType: 'None'
    use32BitWorkerProcess: true
    webSocketsEnabled: false
    alwaysOn: false
    managedPipelineMode: 'Integrated'
    virtualApplications: [
      {
        virtualPath: '/'
        physicalPath: 'site\\wwwroot'
        preloadEnabled: false
      }
    ]
    loadBalancing: 'LeastRequests'
    experiments: {
      rampUpRules: []
    }
    autoHealEnabled: false
    vnetRouteAllEnabled: (virtualNetworkSubnetId != '' ? true : false)
    vnetPrivatePortsCount: 0
    cors: {
      allowedOrigins: [
        'https://portal.azure.com'
      ]
      supportCredentials: false
    }
    localMySqlEnabled: false
    xManagedServiceIdentityId: 18088
    ipSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictionsUseMain: false
    http20Enabled: true
    minTlsVersion: '1.2'
    scmMinTlsVersion: '1.0'
    ftpsState: 'FtpsOnly'
    preWarmedInstanceCount: 1
    functionAppScaleLimit: 10
    functionsRuntimeScaleMonitoringEnabled: false
    minimumElasticInstanceCount: 1
    azureStorageAccounts: {
    }
  }
}

resource functionAppSiteConfig 'Microsoft.Web/sites/config@2022-03-01' = {
  parent: functionAppSite
  name: 'appsettings'
  properties: appSettings
}

// * Slot Staging

resource functionAppSiteSlotStaging 'Microsoft.Web/sites/slots@2022-03-01' = if (slotStagingEnabled) {
  tags: tags
  parent: functionAppSite
  name: 'staging'
  location: location
  kind: kind
  identity: (userAssignedIdentityName != '' ? {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentity.id}': {}
    }
  } : {
    type: 'SystemAssigned'
  })
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: '${functionAppName}--staging.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${functionAppName}--staging.scm.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: appServicePlan.id
    reserved: false
    isXenon: false
    hyperV: false
    vnetRouteAllEnabled: (virtualNetworkSubnetId != '' ? true : false)
    vnetImagePullEnabled: false
    vnetContentShareEnabled: false
    siteConfig: {
      numberOfWorkers: 1
      acrUseManagedIdentityCreds: false
      alwaysOn: false
      http20Enabled: true
      functionAppScaleLimit: 10
      minimumElasticInstanceCount: 1
      connectionStrings: [for connectionString in functionAppConnectionString: {
        name: connectionString.name
        connectionString: connectionString.value
        type: connectionString.type
      }]
    }
    scmSiteAlsoStopped: false
    clientAffinityEnabled: false
    clientCertEnabled: false
    clientCertMode: 'Required'
    hostNamesDisabled: false
    // customDomainVerificationId: '8FFE04AB5CDD5885DA7907BBB36EC1988F280F28FC2C07C526888B653DAB846B'
    containerSize: 1536
    dailyMemoryTimeQuota: 0
    httpsOnly: true
    redundancyMode: 'None'
    storageAccountRequired: false
    virtualNetworkSubnetId: (virtualNetworkSubnetId != '' ? virtualNetworkSubnetId : null)
    keyVaultReferenceIdentity: (userAssignedIdentityName != '' ? userAssignedIdentity.id : null)
  }
}

resource functionAppSiteSlotStagingFtp 'Microsoft.Web/sites/slots/basicPublishingCredentialsPolicies@2022-03-01' = if (slotStagingEnabled) {
  parent: functionAppSiteSlotStaging
  name: 'ftp'
  #disable-next-line BCP187
  location: location
  properties: {
    allow: true
  }
}

resource functionAppSiteSlotStagingScm 'Microsoft.Web/sites/slots/basicPublishingCredentialsPolicies@2022-03-01' = if (slotStagingEnabled) {
  parent: functionAppSiteSlotStaging
  name: 'scm'
  #disable-next-line BCP187
  location: location
  properties: {
    allow: true
  }
}

resource functionAppSiteSlotStagingWeb 'Microsoft.Web/sites/slots/config@2022-03-01' = if (slotStagingEnabled) {
  parent: functionAppSiteSlotStaging
  name: 'web'
  properties: {
    numberOfWorkers: 1
    defaultDocuments: [
      'Default.htm'
      'Default.html'
      'Default.asp'
      'index.htm'
      'index.html'
      'iisstart.htm'
      'default.aspx'
      'index.php'
      'hostingstart.html'
    ]
    netFrameworkVersion: 'v6.0'
    javaVersion: (javaVersion != '' ? javaVersion : null)
    linuxFxVersion: (linuxFxVersion != '' ? linuxFxVersion : null)
    requestTracingEnabled: false
    remoteDebuggingEnabled: false
    remoteDebuggingVersion: 'VS2019'
    httpLoggingEnabled: false
    acrUseManagedIdentityCreds: false
    logsDirectorySizeLimit: 35
    detailedErrorLoggingEnabled: false
    publishingUsername: '$${functionAppName}__staging'
    scmType: 'None'
    use32BitWorkerProcess: true
    webSocketsEnabled: false
    alwaysOn: false
    managedPipelineMode: 'Integrated'
    virtualApplications: [
      {
        virtualPath: '/'
        physicalPath: 'site\\wwwroot'
        preloadEnabled: false
      }
    ]
    loadBalancing: 'LeastRequests'
    experiments: {
      rampUpRules: []
    }
    autoHealEnabled: false
    vnetRouteAllEnabled: (virtualNetworkSubnetId != '' ? true : false)
    vnetPrivatePortsCount: 0
    cors: {
      allowedOrigins: [
        'https://portal.azure.com'
      ]
      supportCredentials: false
    }
    localMySqlEnabled: false
    xManagedServiceIdentityId: 18710
    ipSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictionsUseMain: false
    http20Enabled: true
    minTlsVersion: '1.2'
    scmMinTlsVersion: '1.0'
    ftpsState: 'FtpsOnly'
    preWarmedInstanceCount: 1
    functionAppScaleLimit: 10
    functionsRuntimeScaleMonitoringEnabled: false
    minimumElasticInstanceCount: 1
    azureStorageAccounts: {
    }
  }
}

resource functionAppSiteSlotConfig 'Microsoft.Web/sites/slots/config@2022-03-01' = if (slotStagingEnabled) {
  parent: functionAppSiteSlotStaging
  name: 'appsettings'
  properties: appSettingsSlot
}

// * logs

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'SendToLAW'
  scope: functionAppSite
  properties: {
    workspaceId: appInsights.properties.WorkspaceResourceId
    logs: [
      {
        category: 'FunctionAppLogs'
        enabled: true
      }
    ]
    // metrics: [
    //   {
    //     category: 'AllMetrics'
    //     enabled: false
    //     retentionPolicy: {
    //       days: 30
    //       enabled: true
    //     }
    //   }
    // ]
  }
}



resource evhnsSplunk 'Microsoft.EventHub/namespaces@2022-10-01-preview' existing = {
  name: 'pg-mt-evhns-splunk-${evhnMetricsEnv}-we'
  scope: resourceGroup('rg-monitoring-${evhnMetricsEnv}')

  resource defaultSharedAccessKey 'authorizationRules' existing = {
    name: 'DefaultSharedAccessKey'
  }

  resource evhApps 'eventhubs' existing = {
    name: 'pg-mt-evh-metrics-${evhnMetricsEnv}-001'
  }
}

resource diagnosticSettingsEvh 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (evhnMetricsEnabled) {
  name: 'SendToEvh'
  scope: functionAppSite
  properties: {
    eventHubAuthorizationRuleId: evhnsSplunk::defaultSharedAccessKey.id // '/subscriptions/8055f06c-1c19-49e8-a3c9-9196d6f91c90/resourcegroups/rg-monitoring-noprod/providers/Microsoft.EventHub/namespaces/pg-mt-evhns-splunk-noprod-we/authorizationrules/DefaultSharedAccessKey'
    eventHubName: evhnsSplunk::evhApps.name // 'pg-mt-evh-metrics-noprod-001'
    logs: []
    metrics: [
      {
        timeGrain: null
        enabled: true
        retentionPolicy: {
          days: 0
          enabled: false
        }
        category: 'AllMetrics'
      }
    ]
  }
}

// resource functionLock 'Microsoft.Authorization/locks@2020-05-01' = {
//   name: '${functionAppName}-lock'
//   scope: functionAppSite
//   properties:{
//     level: 'CanNotDelete'
//     notes: 'Component managed by Bicep, and should not be deleted.'
//   }
// }

output functionId string = functionAppSite.id
