param registryName string

param adminPrincipalId string

#disable-next-line no-loc-expr-outside-params
var location = resourceGroup().location

resource registry 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
  name: registryName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    adminUserEnabled: false
    anonymousPullEnabled: true
  }
}

resource acrPushDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: tenant()
  name: '8311e382-0749-4cb8-b61a-304f252e45ec'
}

resource acrPushAssignemnt 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: registry
  name: guid(registry.id, adminPrincipalId)
  properties: {
    principalId: adminPrincipalId
    roleDefinitionId: acrPushDefinition.id
    principalType: 'ServicePrincipal'
  }
}
