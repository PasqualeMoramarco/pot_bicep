@description('Azure Supported Environments')
@allowed([
  'prod'
  'preprod'
  'preprod-temp'
  'qfe'
  'dev'
  'dev-temp'
])
param environment string

output env string = environment
