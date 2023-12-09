param maxMessageSizeInKilobytes int

@description('Service Name, must be an unique string without spaces, max lenght is 255 characters')
@minLength(1)
@maxLength(150)
param serviceBusName string
param requiresDuplicateDetection bool = false
param requiresSession bool = false
param queueName string
param duplicateDetectionHistoryTimeWindow string
param defaultMessageTimeToLive string = 'P14D'
param maxSizeInMegabytes int = 1024
param lockDuration string = 'PT30S'
param maxDeliveryCount int = 10

resource ServiceBus 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' existing = {
  name: serviceBusName

  // GESTIONE DELLE QUEUES
  resource Queues 'queues' = {
    name: queueName
    properties: {
      maxMessageSizeInKilobytes: maxMessageSizeInKilobytes
      lockDuration: lockDuration
      maxSizeInMegabytes: maxSizeInMegabytes
      requiresDuplicateDetection: requiresDuplicateDetection
      requiresSession: requiresSession
      defaultMessageTimeToLive: defaultMessageTimeToLive
      deadLetteringOnMessageExpiration: false
      enableBatchedOperations: true
      duplicateDetectionHistoryTimeWindow: duplicateDetectionHistoryTimeWindow
      maxDeliveryCount: maxDeliveryCount
      status: 'Active'
      autoDeleteOnIdle: 'P10675199DT2H48M5.4775807S'
      enablePartitioning: false
      enableExpress: false
    }

    resource accessKey 'authorizationRules' = {
      name: '${queueName}-access-key'
      properties: {
        rights: [
          'Listen'
          'Send'
        ]
      }
    }
  }
}
