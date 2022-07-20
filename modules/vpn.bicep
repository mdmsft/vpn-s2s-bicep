targetScope = 'subscription'

param resourceGroupName string
param resourceSuffix string
param location string
param gatewayIpAddress string
param virtualNetworkGatewayId string
param deploymentName string
param localNetworkAddressPrefix string

module gateway 'gateway/local.bicep' = {
  scope: resourceGroup(resourceGroupName)
  name: '${deploymentName}-lgw'
  params: {
    gatewayIpAddress: gatewayIpAddress
    resourceSuffix: resourceSuffix
    localNetworkAddressPrefix: localNetworkAddressPrefix
    location: location
  }
}

module connection 'connection.bicep' = {
  scope: resourceGroup(resourceGroupName)
  name: '${deploymentName}-connection'
  params: {
    location: location
    localNetworkGatewayId: gateway.outputs.id
    resourceSuffix: resourceSuffix
    virtualNetworkGatewayId: virtualNetworkGatewayId
  }
}
