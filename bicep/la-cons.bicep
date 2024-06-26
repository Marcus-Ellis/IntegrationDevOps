@description('The name of the logic app to create.')
param logicAppName string


@description('Location for all resources.')
param location string = resourceGroup().location

var workflowSchema = 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'

resource stg 'Microsoft.Logic/workflows@2019-05-01' = {
  name: logicAppName
  location: location
  tags: {
    displayName: logicAppName
  }
  properties: {
    definition: {
      '$schema': workflowSchema
      contentVersion: '1.0.0.0'
      parameters: {}
      triggers: {}
      actions: {}
    }
  }
}

output name string = stg.name
output resourceId string = stg.id
output resourceGroupName string = resourceGroup().name
output location string = location
