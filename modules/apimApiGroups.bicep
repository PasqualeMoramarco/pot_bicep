/////////////////////////////////////
// PARAMETERS                      //
/////////////////////////////////////

param apiManagementName string
param name string
param displayName string
param revision string
param description string
param subscriptionRequired bool
param path string
param format string
param value string
param apiPolicy string

resource apiManagement 'Microsoft.ApiManagement/service@2021-12-01-preview' existing =  {
  name: apiManagementName
  
  resource apiGroupsResource 'apis@2021-12-01-preview' = {
    name: name
    properties: {
      displayName: displayName
      apiRevision: revision
      description: description
      subscriptionRequired: subscriptionRequired
      // serviceUrl: group.ServiceUrl
      path: path
      format: format
      value: value
      protocols: [
        'https'
      ]
      authenticationSettings:{}
      // authenticationSettings: (authorizationServerId == '') ? {} : {
      //   oAuth2: {
      //     authorizationServerId: authorizationServerId
      //   }
      // }
      subscriptionKeyParameterNames: {
        header: 'Ocp-Apim-Subscription-Key'
        query: 'subscription-key'
      }
      isCurrent: true
    }

    resource policy 'policies@2022-04-01-preview' = {
      name: 'policy'
      properties: {
        format: 'xml'
        value: apiPolicy
      }
    }
  }
}
