@description('Resources Group location')
param location string

@description('Resources tags')
param tags object = {}

@description('Resources Name, must be an unique string without spaces')
@minLength(2)
@maxLength(60)
param appName string

param userAssignedIdentitieId string = ''

@description('Default Plan subnet id')
param virtualNetworkSubnetId string = ''

param appServicePlanName string
param appSettings array = []
// param kind string = 'linux'
param appInsightsName string
param alwaysOn bool = false
param ftpsState string = 'FtpsOnly'
param localMySqlEnabled bool = false
param linuxFxVersion string = ''
param windowsFxVersion string = ''
param netFrameworkVersion string = 'v6.0'
param slotStagingEnabled bool = false

resource appInsights 'microsoft.insights/components@2020-02-02' existing = {
  name: appInsightsName
}

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' existing = {
  name: appServicePlanName
}

var appSettingsObject = reduce(appSettings, {}, (cur, next) => union(cur, {
      '${next.name}': next.value
    }
  )
)

var finalAppSettings = union(appSettingsObject,
  {
    APPINSIGHTS_INSTRUMENTATIONKEY: appInsights.properties.InstrumentationKey
    APPLICATIONINSIGHTS_CONNECTION_STRING: appInsights.properties.ConnectionString
  }
)

var slotAppSettings = [for appSetting in appSettings: !startsWith(appSetting.name, 'WEBSITE_') ? appSetting : []]
var finalSlotAppSettings = intersection(slotAppSettings, appSettings)

resource appService 'Microsoft.Web/sites@2022-03-01' = {
  name: appName
  location: location
  tags: tags
  identity: (userAssignedIdentitieId != '' ? {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentitieId}': {}
    }
  } : {
    type: 'SystemAssigned'
  })
  properties: {
    siteConfig: {
      linuxFxVersion: (linuxFxVersion != '' ? linuxFxVersion : null)
      windowsFxVersion: (windowsFxVersion != '' ? windowsFxVersion : null)
      alwaysOn: alwaysOn
      ftpsState: ftpsState
      localMySqlEnabled: localMySqlEnabled
      netFrameworkVersion: netFrameworkVersion
    }
    serverFarmId: appServicePlan.id
    clientAffinityEnabled: false
    httpsOnly: true
  }

  resource functionAppSiteConfig 'config' = {
    name: 'appsettings'
    properties: finalAppSettings
  }

  resource functionAppSlotStaging 'slots' = if (slotStagingEnabled) {
    name: 'staging'
    location: location
    tags: tags
    identity: (userAssignedIdentitieId != '' ? {
      type: 'UserAssigned'
      userAssignedIdentities: {
        '${userAssignedIdentitieId}': {}
      }
    } : {
      type: 'SystemAssigned'
    })
    properties: {
      enabled: true
      httpsOnly: true
      virtualNetworkSubnetId: (virtualNetworkSubnetId != '' ? virtualNetworkSubnetId : null)
    }
  }

  resource functionSlotConfig 'config' = if (slotStagingEnabled) {
    name: 'slotConfigNames'
    properties: {
      appSettingNames: [for appSetting in finalSlotAppSettings: appSetting.name]
    }
  }
}

// resource appService 'Microsoft.Web/sites@2022-03-01' = {
//   name: appName
//   location: location
//   tags: tags
//   kind: kind
//   identity: {
//     type: 'SystemAssigned'
//   }
//   properties: {
//     enabled: true
//     // hostNameSslStates: [
//     //   {
//     //     name: '${appName}.azurewebsites.net'
//     //     sslState: 'Disabled'
//     //     hostType: 'Standard'
//     //   }
//     //   {
//     //     name: '${appName}.scm.azurewebsites.net'
//     //     sslState: 'Disabled'
//     //     hostType: 'Repository'
//     //   }
//     // ]
//     serverFarmId: appServicePlan.id
//     reserved: false
//     isXenon: false
//     hyperV: false
//     vnetRouteAllEnabled: false
//     vnetImagePullEnabled: false
//     vnetContentShareEnabled: false
//     siteConfig: {
//       numberOfWorkers: 1
//       acrUseManagedIdentityCreds: false
//       alwaysOn: alwaysOn
//       appSettings: [for appSetting in finalAppSettings: {
//         name: appSetting.Name
//         value: appSetting.Value
//       }]
//     }
//     // scmSiteAlsoStopped: false
//     clientAffinityEnabled: false
//     clientCertEnabled: false
//     clientCertMode: 'Required'
//     hostNamesDisabled: false
//     httpsOnly: false
//     redundancyMode: 'None'
//     storageAccountRequired: false
//     keyVaultReferenceIdentity: 'SystemAssigned'
//   }

//   resource FTPCredentialsPolicies 'basicPublishingCredentialsPolicies' = {
//     name: 'ftp'
//     properties: {
//       allow: true
//     }
//   }

//   resource webCredentialsPolicies 'config' = {
//     name: 'web'
//     properties: {
//       numberOfWorkers: 1
//       defaultDocuments: [
//         'Default.htm'
//         'Default.html'
//         'Default.asp'
//         'index.htm'
//         'index.html'
//         'iisstart.htm'
//         'default.aspx'
//         'index.php'
//       ]
//       netFrameworkVersion: 'v6.0'
//       requestTracingEnabled: false
//       remoteDebuggingEnabled: false
//       remoteDebuggingVersion: 'VS2019'
//       httpLoggingEnabled: false
//       acrUseManagedIdentityCreds: false
//       logsDirectorySizeLimit: 35
//       detailedErrorLoggingEnabled: false
//       publishingUsername: appName
//       scmType: 'None'
//       use32BitWorkerProcess: true
//       webSocketsEnabled: false
//       alwaysOn: false
//       managedPipelineMode: 'Integrated'
//       virtualApplications: [
//         {
//           virtualPath: '/'
//           physicalPath: 'site\\wwwroot'
//           preloadEnabled: false
//         }
//       ]
//       loadBalancing: 'LeastRequests'
//       experiments: {
//         rampUpRules: []
//       }
//       autoHealEnabled: false
//       // vnetName: '239f66ba-5a92-4474-9c6f-6808b0dbe1ea_${subnetName}'
//       vnetRouteAllEnabled: false
//       vnetPrivatePortsCount: 0
//       cors: {
//         allowedOrigins: [
//           'https://portal.azure.com'
//         ]
//         supportCredentials: false
//       }
//       localMySqlEnabled: localMySqlEnabled
//       // managedServiceIdentityId: 27269
//       // ipSecurityRestrictions: [
//       //   {
//       //     ipAddress: 'Any'
//       //     action: 'Allow'
//       //     priority: 2147483647
//       //     name: 'Allow all'
//       //     description: 'Allow all access'
//       //   }
//       // ]
//       // scmIpSecurityRestrictions: [
//       //   {
//       //     ipAddress: 'Any'
//       //     action: 'Allow'
//       //     priority: 2147483647
//       //     name: 'Allow all'
//       //     description: 'Allow all access'
//       //   }
//       // ]
//       // scmIpSecurityRestrictionsUseMain: false
//       http20Enabled: true
//       minTlsVersion: '1.2'
//       // scmMinTlsVersion: '1.0'
//       ftpsState: ftpsState
//       preWarmedInstanceCount: 1
//       // functionsRuntimeScaleMonitoringEnabled: false
//       minimumElasticInstanceCount: 1
//       // azureStorageAccounts: {
//       // }
//     }
//   }
// }

// resource SCMCredentialsPolicies 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-03-01' = {
//   parent: app
//   name: 'scm'
//   properties: {
//     allow: true
//   }
// }

// resource HostNameBindings 'Microsoft.Web/sites/hostNameBindings@2022-03-01' = {
//   parent: app
//   name: '${appName}.azurewebsites.net'
//   properties: {
//     siteName: appName
//     hostNameType: 'Verified'
//   }
// }

resource diagnosticSetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'SendToLAW'
  scope: appService
  properties: {
    workspaceId: appInsights.properties.WorkspaceResourceId
    logs: [
      {
        category: 'AppServiceHTTPLogs'
        enabled: true
      }
      {
        category: 'AppServiceConsoleLogs'
        enabled: false
      }
      {
        category: 'AppServiceAuditLogs'
        enabled: false
      }
      {
        category: 'AppServiceIPSecAuditLogs'
        enabled: false
      }
      {
        category: 'AppServicePlatformLogs'
        enabled: false
      }
      {
        category: 'AppServiceAppLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true
        }
      }
    ]
  }
}

output appServiceId string = appService.id
