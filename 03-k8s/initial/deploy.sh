#!/bin/bash

az group create --location westus --resource-group antdemo2
az deployment group create --template-file main.bicep --parameters @main.parameters.json --resource-group antdemo2