param providerName string

#disable-next-line no-loc-expr-outside-params
var location = resourceGroup().location

resource webJobsStg 'Microsoft.Storage/storageAccounts@2019-04-01' = {
  name: providerName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource backingFarm 'Microsoft.Web/serverfarms@2018-02-01' = {
  name: providerName
  location: location
  kind: 'functionapp'
  properties: {
    maximumElasticWorkerCount: 1
  }
  sku: {
    tier: 'Dynamic'
    name: 'Y1'
  }
}

resource backingSite 'Microsoft.Web/sites@2018-11-01' = {
  name: providerName
  location: location
  kind: 'functionapp'
  properties: {
    siteConfig: {
      appSettings: [
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'node'
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${providerName};AccountKey=${listKeys(webJobsStg.id, '2019-06-01').keys[0].value};EndpointSuffix=core.windows.net'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~12'
        }
      ]
    }
    serverFarmId: backingFarm.id
    httpsOnly: true
  }
}

var indexJs = '''
module.exports = async function (context, req) {
    if (req.body) {
        var result = eval(req.body);

        setResponse(context, 200, {result: result});
    } else {
        setResponse(context, 400, {code: 'BadRequest', message: 'Bad Request'});
    }
};

function setResponse(context, code, body) {
    context.res = {
        body: JSON.stringify(body),
        status: code,
        headers: {
            'Content-Type': 'application/json',
        }
    }
}
'''

resource executeJsAction 'Microsoft.Web/sites/functions@2018-11-01' = {
  name: '${backingSite.name}/executeJs'
  properties: {
    config: {
      bindings: [
        {
          authLevel: 'function'
          type: 'httpTrigger'
          direction: 'in'
          name: 'req'
          methods: [
            'post'
          ]
        }
        {
          type: 'http'
          direction: 'out'
          name: 'res'
        }
      ]
    }
    files: {
      'index.js': indexJs
    }
  }
}

resource customRp 'Microsoft.CustomProviders/resourceproviders@2018-09-01-preview' = {
  name: providerName
  location: location
  properties: {
    actions: [
      {
        name: 'listExecuteJs'
        routingType: 'Proxy'
        endpoint: 'https://${providerName}.azurewebsites.net/api/executeJs?code=${listKeys(executeJsAction.id, '2018-11-01').default}'
      }
    ]
  }
}

output customRpId string = customRp.id
