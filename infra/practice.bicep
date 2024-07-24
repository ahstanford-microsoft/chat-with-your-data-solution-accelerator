// These parameters will be used to fill in attributes in the Azure Resources.
param location string = resourceGroup().location;
param appPlanName string = '${uniqueString(resourceGroup().id)}plan';

// Create an App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: 'name'
  location: location
  sku: {
    name: 'F1'
    capacity: 1
  }
}

