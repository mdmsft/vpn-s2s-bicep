param resourceSuffix string
param location string = resourceGroup().location
param gatewayIpAddress string
param localNetworkAddressPrefix string

resource gateway 'Microsoft.Network/localNetworkGateways@2022-01-01' = {
  name: 'lgw-${resourceSuffix}'
  location: location
  properties: {
    gatewayIpAddress: gatewayIpAddress
    localNetworkAddressSpace: {
      addressPrefixes: [
        localNetworkAddressPrefix
      ]
    }
  }
}

output id string = gateway.id
