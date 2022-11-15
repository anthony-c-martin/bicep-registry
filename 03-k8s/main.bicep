param baseName string

resource aks 'Microsoft.ContainerService/managedClusters@2022-04-01' existing = {
  name: baseName
}

module kubernetes './manifest.bicep' = {
  name: 'buildbicep-deploy'
  params: {
    kubeConfig: aks.listClusterAdminCredential().kubeconfigs[0].value
  }
}
