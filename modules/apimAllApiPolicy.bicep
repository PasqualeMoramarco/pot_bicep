/////////////////////////////////////
// PARAMETERS                      //
/////////////////////////////////////

param apiManagementName string
param policyName string
param policyFormat string
param policyValue string

resource apiManagement 'Microsoft.ApiManagement/service@2021-12-01-preview' existing =  {
  name: apiManagementName

  resource namedValuesResource 'policies@2022-04-01-preview' = {
    name: policyName
    properties: {
      format: policyFormat
      value: policyValue
    }
  }
}
