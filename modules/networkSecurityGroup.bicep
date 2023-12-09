@description('Resources Group location')
param location string

@description('Resources tags')
param tags object = {}

param networkSecurityGroupName string
param networkSecurityGroupNameRules array = []

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: networkSecurityGroupName
  location: location
  tags: tags

  properties: {

    securityRules: [for securityRule in networkSecurityGroupNameRules: {

        name: securityRule.name
        properties: {
          protocol: securityRule.protocol
          sourcePortRange: securityRule.sourcePortRange
          destinationPortRange: securityRule.destinationPortRange
          sourceAddressPrefix: securityRule.sourceAddressPrefix
          destinationAddressPrefix: securityRule.destinationAddressPrefix
          access: securityRule.access
          priority: securityRule.priority
          direction: securityRule.direction
          sourcePortRanges: securityRule.sourcePortRanges
          destinationPortRanges: securityRule.destinationPortRanges
          sourceAddressPrefixes: securityRule.sourceAddressPrefixes
          destinationAddressPrefixes: securityRule.destinationAddressPrefixes
          destinationApplicationSecurityGroups: securityRule.destinationApplicationSecurityGroups
          description: securityRule.description
          sourceApplicationSecurityGroups: securityRule.sourceApplicationSecurityGroups
        }
    }]
  }
}
