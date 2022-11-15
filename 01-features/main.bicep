// /* Scenario: Module registry */
// resource aks 'Microsoft.ContainerService/managedClusters@2022-04-01' existing = {
//   name: 'myAksCluster'
// }

// // az bicep publish --file main.bicep --target antbicepregistry.azurecr.io/bicep-on-k8s:0.1
// module kubernetes 'br:antbicepregistry.azurecr.io/bicep-on-k8s:0.1' = {
//   name: 'buildbicep-deploy'
//   params: {
//     kubeConfig: aks.listClusterAdminCredential().kubeconfigs[0].value
//   }
// }

// /* Scenario: Linters/TTK Parity */
// @secure()
// param mySecret string
// var concatted = 'abc${123}def'
// output foo string = mySecret

// /* Scenario: filter */
// resource myVnet 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
//   name: 'foo'
// }

// output subnetId string = filter(myVnet.properties.subnets, subnet => subnet.name == 'frontend')[0].id

// /* Scenario: loadJsonContent, items, reduce */
// var roleDefinitions = loadJsonContent('./roles.json').roleDefinitions
// output roleDefinitionIds object = reduce(items(roleDefinitions), {}, (cur, next) => union(cur, {
//   '${next.key}': resourceId('Microsoft.Authorization/roleDefinitions', next.value)
// }))

// /* Scenario: map, filter */
// output acrRoleDefinitons array = map(
//   filter(
//     items(roleDefinitions),
//     k => contains(k.key, 'Acr')),
//   k => k.value)
