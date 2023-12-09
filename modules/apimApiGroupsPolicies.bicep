/////////////////////////////////////
// PARAMETERS                      //
/////////////////////////////////////

@description('Service Name, must be an unique string without spaces, max lenght is 255 characters')
@minLength(1)
@maxLength(255)
param apiManagementName string
param apiName string
param policyFormat string
param policyValue string
param policyName string

resource apiManagement 'Microsoft.ApiManagement/service@2021-12-01-preview' existing =  {
  name: apiManagementName
  
  resource apiGroupsResource 'apis@2022-04-01-preview' existing = {
    name: apiName

    resource apiPolicies 'policies@2022-04-01-preview' = {
      name: policyName
      properties: {
        format: policyFormat
        value: policyValue
      }
    }
  }
}
