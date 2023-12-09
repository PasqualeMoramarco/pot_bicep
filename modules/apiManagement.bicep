/////////////////////////////////////
// PARAMETERS                      //
/////////////////////////////////////
@description('Resources Group location')
param location string

@description('Resources tags')
param tags object = {}

@description('Service Name, must be an unique string without spaces, max lenght is 255 characters')
@minLength(1)
@maxLength(255)
param apiManagementName string

// param namedValues array
param products array
// param apiGroups array
// param apiGroupsPolicies array
param subnetResourceId string
param virtualNetworkType string
// param ProductApiGroupLinks object

// PARAMS APP INSIGHTS
param appInsightName string
param hostName string = '${apiManagementName}.azure-api.net'

resource appInsight 'microsoft.insights/components@2020-02-02' existing = {
  name: appInsightName
}


// API MANAGEMENT
resource apiManagement 'Microsoft.ApiManagement/service@2021-12-01-preview' = {
  name: apiManagementName
  location: location
  tags: tags
  sku: {
    name: 'Premium'
    capacity: 1
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publisherEmail: 'email@organizationemail.it'
    publisherName: 'Prada'
    notificationSenderEmail: 'apimgmt-noreply@mail.windowsazure.com'
    hostnameConfigurations: [
      {
        type: 'Proxy'
        hostName: hostName
        negotiateClientCertificate: false
        defaultSslBinding: true
        certificateSource: 'BuiltIn'
      }
    ]
    customProperties: {
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls11': 'true'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls10': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls11': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls10': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Ssl30': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Protocols.Server.Http2': 'true'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TripleDes168': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Ssl30': 'false'
    }
    virtualNetworkType: virtualNetworkType
    virtualNetworkConfiguration: {
      subnetResourceId: subnetResourceId
    }
    disableGateway: false
    apiVersionConstraint: {}
    publicNetworkAccess: 'Enabled'
  }
}

// GESTIONE DIAGNOSTIC SETTINGS
param diagnosticSettingsName string
resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: diagnosticSettingsName
  scope: apiManagement
  properties: {
    logAnalyticsDestinationType: 'Dedicated'
    workspaceId: appInsight.properties.WorkspaceResourceId
    logs: [
      {
        category: 'GatewayLogs'
        categoryGroup: null
        enabled: true
        retentionPolicy: {
          days: 0
          enabled: false
        }
      }
    ]
    metrics: [
      {
        timeGrain: null
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

param evhnMetricsEnabled bool = false
param evhnMetricsEnv string = ''
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
  scope: apiManagement
  properties: {
    eventHubAuthorizationRuleId: evhnsSplunk::defaultSharedAccessKey.id // '/subscriptions/8055f06c-1c19-49e8-a3c9-9196d6f91c90/resourcegroups/rg-monitoring-noprod/providers/Microsoft.EventHub/namespaces/pg-mt-evhns-splunk-noprod-we/authorizationrules/DefaultSharedAccessKey'
    eventHubName: evhnsSplunk::evhApps.name // 'pg-mt-evh-metrics-noprod-001'
    logs: []
    metrics: [
      {
        timeGrain: null
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          days: 0
          enabled: false
        }
      }
    ]
  }
}

output apiManagementName string = apiManagement.name

// // GESTIONE NAMED VALUES
// resource namedValuesResource 'Microsoft.ApiManagement/service/namedValues@2021-12-01-preview' = [for namedValue in namedValues: {
//   parent: apiManagement
//   name: namedValue.Name
//   properties: {
//     displayName: namedValue.DisplayName
//     secret: namedValue.Secret
//     // value: namedValue.Value
//     tags: array(namedValue.tags)
//     keyVault: {
//       secretIdentifier: namedValue.secretIdentifier
//     }
//   }
// }]

// GESTIONE PRODUCTS
resource productsResource 'Microsoft.ApiManagement/service/products@2021-12-01-preview' = [for (product, index) in products: {
  parent: apiManagement
  name: product.name
  properties: {
    displayName: product.displayName
    description: product.description
    subscriptionRequired: product.subscriptionRequired
    state: product.State
  }
}]

// GESTIONE API GROUPS
// resource apiGroupsResource 'Microsoft.ApiManagement/service/apis@2021-12-01-preview' = [for (group, index) in apiGroups: {
//   parent: apiManagement
//   name: group.Name
//   properties: {
//     displayName: group.displayName
//     apiRevision: group.revision
//     description: group.description
//     subscriptionRequired: group.subscriptionRequired
//     // serviceUrl: group.ServiceUrl
//     path: group.path
//     format: group.format
//     value: group.value
//     protocols: [
//       'https'
//     ]
//     authenticationSettings:{}
//     // authenticationSettings: (group.AuthorizationServerId == '') ? {} : {
//     //   oAuth2: {
//     //     authorizationServerId: group.AuthorizationServerId
//     //   }
//     // }
//     subscriptionKeyParameterNames: {
//       header: 'Ocp-Apim-Subscription-Key'
//       query: 'subscription-key'
//     }
//     isCurrent: true
//   }
// }]

// resource apiPolicies 'Microsoft.ApiManagement/service/apis/policies@2022-04-01-preview' = [for (policy, index) in apiGroups: {
//   name: policy.policyName
//   parent: policy.name
//   properties: {
//     format: policy.policyFormat
//     value: policy.policyValue
//   }
// }]

// GESTIONE POLICIES
// resource policies 'microsoft.apimanagement/service/products/policies@2021-12-01-preview' = [for policy in Products: {
//   name: '${apiManagement.name}/policy'
//   properties: {
//     value: policy.PolicyDefinition
//     format: 'xml'
//   }
// }]

// ASSOCIAZIONE PRODUCT A GRUPPO DI API

// Add custom policy to product
// resource apimProductPolicy 'Microsoft.ApiManagement/service/products/policies@2019-12-01' = {
//   name: '${apiManagement.name}/policy'
//   properties: {
//     format: 'rawxml'
//     value: '<policies><inbound><base /></inbound><backend><base /></backend><outbound><set-header name="Server" exists-action="delete" /><set-header name="X-Powered-By-PIPPO" exists-action="delete" /><set-header name="X-AspNet-Version" exists-action="delete" /><base /></outbound><on-error><base /></on-error></policies>'
//   }
// }

// resource prod 'Microsoft.ApiManagement/service/products@2021-12-01-preview' existing = {
//   name: ProductApiGroupLinks.ProductName
// }

// resource productLinkToApiGroup 'Microsoft.ApiManagement/service/products/apis@2021-12-01-preview' = {
//   parent: prod
//   name: ProductApiGroupLinks.ApiGroupName
// }

// GESTIONE LOG ANALYTICS




// GESTIONE APP INSIGHTS
resource loggerAppiApim 'Microsoft.ApiManagement/service/loggers@2021-12-01-preview' = {
  parent: apiManagement
  name: appInsightName
  properties: {
    loggerType: 'applicationInsights'
    credentials: {
      instrumentationKey: appInsight.properties.InstrumentationKey
    }
    isBuffered: true
    resourceId: appInsight.id
  }
}

// GESTIONE ALL API APPLICATION INSIGHTS
resource apiManagementAppInsightsAllAPI 'Microsoft.ApiManagement/service/diagnostics@2021-12-01-preview' = {
  parent: apiManagement
  name: 'applicationinsights'
  properties: {
    alwaysLog: 'allErrors'
    httpCorrelationProtocol: 'Legacy'
    verbosity: 'verbose'
    logClientIp: true
    loggerId: loggerAppiApim.id
    sampling: {
      samplingType: 'fixed'
      percentage: 100
    }
    frontend: {
      request: {
        headers: [
          'X-api-request-correlation-id'
          'X-api-client-correlation-id'
          'true-client-ip'
          'WCSessionId'
          'WCStoreID'
          'wc_user_email'
          'wc_token'
          'wc_trusted_token'
          'wc_user_validated'
          'Authorization'
          'WCUserId'
          'Accept-Language'
          'User-Agent'
          'storeId'
          'SAPCCAccessToken'
          'x-functions-key'
          'OrderId'
          'flex.signature'
          'fluent-signature'
        ]
        body: {
          bytes: 8192
        }
      }
      response: {
        headers: [
          'X-api-request-correlation-id'
          'X-api-client-correlation-id'
          'true-client-ip'
          'WCSessionId'
          'WCStoreID'
          'wc_user_email'
          'wc_token'
          'wc_trusted_token'
          'wc_user_validated'
          'Authorization'
          'WCUserId'
          'Accept-Language'
          'User-Agent'
          'storeId'
          'SAPCCAccessToken'
          'x-functions-key'
          'OrderId'
          'flex.signature'
          'fluent-signature'
        ]
        body: {
          bytes: 8192
        }
      }
    }
    backend: {
      request: {
        headers: [
          'X-api-request-correlation-id'
          'X-api-client-correlation-id'
          'true-client-ip'
          'WCSessionId'
          'WCStoreID'
          'wc_user_email'
          'wc_token'
          'wc_trusted_token'
          'wc_user_validated'
          'Authorization'
          'WCUserId'
          'Accept-Language'
          'User-Agent'
          'storeId'
          'SAPCCAccessToken'
          'x-functions-key'
          'OrderId'
          'flex.signature'
          'fluent-signature'
        ]
        body: {
          bytes: 8192
        }
      }
      response: {
        headers: [
          'X-api-request-correlation-id'
          'X-api-client-correlation-id'
          'true-client-ip'
          'WCSessionId'
          'WCStoreID'
          'wc_user_email'
          'wc_token'
          'wc_trusted_token'
          'wc_user_validated'
          'Authorization'
          'WCUserId'
          'Accept-Language'
          'User-Agent'
          'storeId'
          'SAPCCAccessToken'
          'x-functions-key'
          'OrderId'
          'flex.signature'
          'fluent-signature'
        ]
        body: {
          bytes: 8192
        }
      }
    }
  }
}

// GESTIONE ALL API AZURE MONITOR
resource loggerAzureMonitor 'Microsoft.ApiManagement/service/loggers@2022-04-01-preview' = {
  parent: apiManagement
  name: 'azureMonitor'
  properties: {
    loggerType: 'azureMonitor'
    isBuffered: true
  }
}

resource apiManagementAzureMonitorAllAPI 'Microsoft.ApiManagement/service/diagnostics@2021-12-01-preview' = {
  parent: apiManagement
  name: 'azureMonitor'
  properties: {
    alwaysLog: 'allErrors'
    verbosity: 'verbose'
    logClientIp: true
    loggerId: loggerAzureMonitor.id
    sampling: {
      samplingType: 'fixed'
      percentage: 100
    }
    frontend: {
      request: {
        headers: [
          'X-api-request-correlation-id'
          'X-api-client-correlation-id'
          'true-client-ip'
          'WCSessionId'
          'WCStoreID'
          'wc_user_email'
          'wc_token'
          'wc_trusted_token'
          'wc_user_validated'
          'Authorization'
          'WCUserId'
          'Accept-Language'
          'User-Agent'
          'SAPCCAccessToken'
          'x-functions-key'
          'OrderId'
          'storeId'
          'flex.signature'
          'fluent-signature'
        ]
        body: {
          bytes: 8192
        }
      }
      response: {
        headers: [
          'X-api-request-correlation-id'
          'X-api-client-correlation-id'
          'true-client-ip'
          'WCSessionId'
          'WCStoreID'
          'wc_user_email'
          'wc_token'
          'wc_trusted_token'
          'wc_user_validated'
          'Authorization'
          'WCUserId'
          'Accept-Language'
          'User-Agent'
          'SAPCCAccessToken'
          'x-functions-key'
          'OrderId'
          'storeId'
          'flex.signature'
          'fluent-signature'
        ]
        body: {
          bytes: 8192
        }
      }
    }
    backend: {
      request: {
        headers: [
          'X-api-request-correlation-id'
          'X-api-client-correlation-id'
          'true-client-ip'
          'WCSessionId'
          'WCStoreID'
          'wc_user_email'
          'wc_token'
          'wc_trusted_token'
          'wc_user_validated'
          'Authorization'
          'WCUserId'
          'Accept-Language'
          'User-Agent'
          'SAPCCAccessToken'
          'x-functions-key'
          'OrderId'
          'storeId'
          'flex.signature'
          'fluent-signature'
        ]
        body: {
          bytes: 8192
        }
      }
      response: {
        headers: [
          'X-api-request-correlation-id'
          'X-api-client-correlation-id'
          'true-client-ip'
          'WCSessionId'
          'WCStoreID'
          'wc_user_email'
          'wc_token'
          'wc_trusted_token'
          'wc_user_validated'
          'Authorization'
          'WCUserId'
          'Accept-Language'
          'User-Agent'
          'SAPCCAccessToken'
          'x-functions-key'
          'OrderId'
          'storeId'
          'flex.signature'
          'fluent-signature'
        ]
        body: {
          bytes: 8192
        }
      }
    }
  }
}
