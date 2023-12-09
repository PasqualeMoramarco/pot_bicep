output name string = toLower(location)
output code string = locations[toLower(location)].code

@description('Azure Locations, last update: 2023-07-03')
param location string
var locations = {
  australiaeast: {
    displayName: 'Australia East'
    code: 'ae'
  }
  southeastasia: {
    displayName: 'Southeast Asia'
    code: 'sa'
  }
  northeurope: {
    displayName: 'North Europe'
    code: 'ne'
  }
  westeurope: {
    displayName: 'West Europe'
    code: 'we'
  }
  chinaeast2: {
    displayName: 'China East 2'
    code: 'ce2'
  }
  chinanorth3: {
    displayName: 'China North 3'
    code: 'cn3'
  }
  japaneast: {
    displayName: 'Japan East'
    code: 'je'
  }
  koreacentral: {
    displayName: 'Korea Central'
    code: 'kc'
  }
  canadacentral: {
    displayName: 'Canada Central'
    code: 'cc'
  }
  norwayeast: {
    displayName: 'Norway East'
    code: 'ne'
  }
  brazilsouth: {
    displayName: 'Brazil South'
    code: 'bs'
  }
}
