param eventHubName string
param partitionCount int = 1
param messageRetentionInDays int = 1
param status string = 'Active'
param nameSpaceName string


resource eventHubNameSpace 'Microsoft.EventHub/namespaces@2022-10-01-preview' existing =  {
  name: nameSpaceName
}

resource eventhub 'Microsoft.EventHub/namespaces/eventhubs@2022-01-01-preview' = {
  parent: eventHubNameSpace
  name: eventHubName
  properties: {
    messageRetentionInDays: messageRetentionInDays
    partitionCount: partitionCount
    status: status
  }

  resource consumer 'consumergroups' = {
    name: '$Default'
  }
}
