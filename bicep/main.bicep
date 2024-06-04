targetScope = 'subscription'

param projectName string
param region string
param environmentName string

param AzureBlob_ConnectionString string
param cognitiveservicescomputervision_ConnectionKey string
param AzureBlob_V2_ConnectionKey string


resource projectRG 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: format('{0}-{1}-rg', projectName, environmentName)
  location: region
}

module functionApp 'fa.bicep' = {
  name: 'functionAppModule'
  params: {
    functionAppName: format('{0}-{1}-fa', projectName, environmentName)
    location: projectRG.location
  }
  scope: resourceGroup(projectRG.name)
}

module logicApp 'la-cons.bicep' = {
  name: 'logicAppModuleConsumption'
  params: {
    logicAppName: format('{0}-{1}-cons-la', projectName, environmentName)
    location: projectRG.location
  }
  scope: resourceGroup(projectRG.name)
}

var logicAppStdName = format('{0}-{1}-std-la', projectName, environmentName)

module logicAppStdComputerVisionConnector 'la-std-conn-cv.bicep' = {
  name: 'logicAppModuleStandardComputerVisionConnector'
  params: {
    cognitiveServicesAccountResourceGroup: 'IntegrateWithRG'
    cvConnectionName: 'cognitiveservicescomputervision'
    cvAccountName: 'ComputerVisionAvara'
  }
  scope: resourceGroup(projectRG.name)
}

module logicAppStdBlobConnector 'la-std-conn-blob.bicep' = {
  name: 'logicAppModuleStandardComputerBlobConnector'
  params: {
    blobServiceResourceGroup: 'IntegrateWithRG'
    blobConnectionName: 'AzureBlob_V2'
    blobAccountName: 'storageaccavara'
    location: projectRG.location
  }
  scope: resourceGroup(projectRG.name)
}

module logicAppStd 'la-std.bicep' = {
  name: 'logicAppModuleStandard'
  params: {
    logicAppName: logicAppStdName
    location: projectRG.location
    AzureBlob_ConnectionString: AzureBlob_ConnectionString
    cognitiveservicescomputervision_ConnectionKey: cognitiveservicescomputervision_ConnectionKey
    AzureBlob_V2_ConnectionKey: AzureBlob_V2_ConnectionKey
    cognitiveservicescomputervision_ConnectionRuntimeUrl: logicAppStdComputerVisionConnector.outputs.apiConnectionUrl
    AzureBlob_V2_ConnectionRuntimeUrl: logicAppStdBlobConnector.outputs.apiConnectionUrl
  }
  scope: resourceGroup(projectRG.name)
}


module logicAppStdComputerVisionConnectorPolicy 'la-std-connections-policy.bicep' = {
  name: 'logicAppModuleStandardComputerVisionConnectorPolicy'
  params: {
    connectionName: logicAppStdComputerVisionConnector.outputs.apiConnectionName
    tenantId: logicAppStd.outputs.tenantId
    principalId: logicAppStd.outputs.principalId
    location: projectRG.location
  }
  scope: resourceGroup(projectRG.name)
}

module logicAppStdBlobConnectorPolicy 'la-std-connections-policy.bicep' = {
  name: 'logicAppModuleStandardBlobConnectorPolicy'
  params: {
    connectionName: logicAppStdBlobConnector.outputs.apiConnectionName
    tenantId: logicAppStd.outputs.tenantId
    principalId: logicAppStd.outputs.principalId
    location: projectRG.location
  }
  scope: resourceGroup(projectRG.name)
}

// TODO: update logic app app settings
 


output systemAssignedIdentityObjectId string = logicAppStd.outputs.principalId
output systemAssignedIdentityPrincipalId string = logicAppStd.outputs.tenantId

