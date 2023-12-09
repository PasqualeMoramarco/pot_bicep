@description('Role Scope name')
param scopeName string


@description('Roles')
param roles array = [
  // {
  //   roleDefinitionId: 'roleDefinitionId'
  //   principalId: 'principalId'
  //   principalType: 'principalType'
  // }
]

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for rbac in roles : {
  name: guid(scopeName, rbac.roleDefinitionId, rbac.principalId, rbac.principalType)
  properties: {
    principalType: rbac.principalType
    principalId: rbac.principalId
    roleDefinitionId: rbac.roleDefinitionId
    description: '${scopeName} (Role assigned with Bicep)'
  }
}]
