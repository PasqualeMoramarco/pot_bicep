param maxMessageSizeInKilobytes int

@description('Service Name, must be an unique string without spaces, max lenght is 255 characters')
@minLength(1)
@maxLength(150)
param serviceBusName string
param maxSizeInMegabytes int
param topicName string
param defaultMessageTimeToLive string = 'P14D'
param requiresDuplicateDetection bool
param duplicateDetectionHistoryTimeWindow string = 'PT10M'
param subscriptions array

resource ServiceBus 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' existing = {
  name: serviceBusName

  // GESTIONE DEI TOPICS
  resource Topics 'topics' = {
    name: topicName
    properties: {
      maxMessageSizeInKilobytes: maxMessageSizeInKilobytes
      defaultMessageTimeToLive: defaultMessageTimeToLive
      maxSizeInMegabytes: maxSizeInMegabytes
      requiresDuplicateDetection: requiresDuplicateDetection
      duplicateDetectionHistoryTimeWindow: duplicateDetectionHistoryTimeWindow
      enableBatchedOperations: true
      status: 'Active'
      supportOrdering: true
      autoDeleteOnIdle: 'P10675199DT2H48M5.4775807S'
      enablePartitioning: false
      enableExpress: false
    }

    resource accessKey 'authorizationRules' = {
      name: '${topicName}-access-key'
      properties: {
        rights: [
          'Listen'
          'Send'
        ]
      }
    }
  }
}

module sbusSubscription '../modules/serviceBusSubscriptions.bicep' = [for (item, index) in subscriptions: {
  name: '${deployment().name}.sbusSubscription${index}'
  params: {
    serviceBusName: serviceBusName
    subscription: {
      topicName: topicName
      name: item.name
      requiresSession: (contains(item, 'requiresSession') ? item.requiresSession : false)
      rules: (contains(item,'rules') ? item.rules : [])
      maxDeliveryCount: (contains(item, 'maxDeliveryCount') ? item.maxDeliveryCount : 10)
    }
  }
  dependsOn: [ ServiceBus::Topics ]
}]
