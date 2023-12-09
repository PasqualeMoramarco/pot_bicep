/////////////////////////////////////
// PARAMETERS                      //
/////////////////////////////////////

param apiManagementName string
param subscriptionName string
param subscriptionDisplayName string
param subscriptionState string
param subscriptionApiName string

resource apiManagement 'Microsoft.ApiManagement/service@2021-12-01-preview' existing =  {
  name: apiManagementName

  resource api 'apis@2022-04-01-preview' existing = {
    name: subscriptionApiName
  }

  resource subscription 'subscriptions@2022-04-01-preview' = {
    name: subscriptionName
    properties: {
      allowTracing: false
      displayName: subscriptionDisplayName
      scope: api.id
      state: subscriptionState
    }
  }
}
