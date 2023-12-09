// * PARAMS
@description('Resources Group locations')
param location string

@description('Resources tags')
param tags object = {}

@description('Resources Name, most be an unique string without spaces')
@minLength(3)
@maxLength(25)
param userAssignedIdentitieName string


resource userAssignedIdentitie 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: userAssignedIdentitieName
  location: location
  tags: tags
}
