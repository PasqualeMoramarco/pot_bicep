@description('Resources Group location')
param location string


@description('Resources tags')
param tags object = {}


param OriginHostName string
param originPath string
param endpointName string
param cdnProfilesName string
param OriginHostAlias string = replace(OriginHostName ,'.', '-')



param contentTypesToCompress array = []
// * VARIABLES


resource cdnProfile 'Microsoft.Cdn/profiles@2022-11-01-preview' existing = {
  name: cdnProfilesName
}

resource cdnVerizonEndpoint 'Microsoft.Cdn/profiles/endpoints@2022-11-01-preview' = {
  parent: cdnProfile
  name: endpointName
  location: location
  tags: tags
  properties: {
    originHostHeader: OriginHostName
    originPath: originPath
    contentTypesToCompress: contentTypesToCompress
    isCompressionEnabled: true
    isHttpAllowed: false
    isHttpsAllowed: true
    queryStringCachingBehavior: 'UseQueryString'
    optimizationType: 'GeneralWebDelivery'
    origins: [
      {
        name: OriginHostAlias
        properties: {
          hostName: OriginHostName
        }
      }
    ]
    originGroups: []
    geoFilters: []
    urlSigningKeys: []
  }
}

resource CdnVerizonOrigin 'Microsoft.Cdn/profiles/endpoints/origins@2022-11-01-preview' = {
  parent: cdnVerizonEndpoint
  name: OriginHostAlias
  properties: {
    hostName: OriginHostName
  }
}
