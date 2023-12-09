@description('Service Name, must be an unique string without spaces, max lenght is 255 characters')
@minLength(1)
@maxLength(150)
param serviceBusName string
param subscription object

resource ServiceBus 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' existing = {
  name: serviceBusName
  
  resource topic 'topics' existing = {
    name: subscription.topicName

    resource serviceBusSubscription 'subscriptions' = {
      name: subscription.name
      properties: {
        isClientAffine: false
        lockDuration: 'PT30S'
        requiresSession: subscription.requiresSession
        defaultMessageTimeToLive: 'P14D'
        deadLetteringOnMessageExpiration: false
        deadLetteringOnFilterEvaluationExceptions: false
        maxDeliveryCount: subscription.maxDeliveryCount
        status: 'Active'
        enableBatchedOperations: true
        autoDeleteOnIdle: 'P14D'
      }
    
      resource serviceBusSubscriptionFilter 'rules' = [for rule in subscription.rules : {
        name: rule.name
        properties: {
          // action: {
          // }
          filterType: rule.type 
          sqlFilter: (rule.type   == 'SqlFilter' ? {
            sqlExpression: rule.value
            compatibilityLevel: 20
          }:null)
          correlationFilter: (rule.type   == 'CorrelationFilter' ? {
            label: rule.value
          }:null)
        }
      }]
    }
  }
}
