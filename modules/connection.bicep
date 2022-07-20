param resourceSuffix string
param location string = resourceGroup().location
param virtualNetworkGatewayId string
param localNetworkGatewayId string

resource connection 'Microsoft.Network/connections@2022-01-01' = {
  name: 'con-${resourceSuffix}'
  location: location
  properties: {
    connectionType: 'IPsec'
    virtualNetworkGateway1: {
      id: virtualNetworkGatewayId
      properties: {}
    }
    localNetworkGateway2: {
      id: localNetworkGatewayId
      properties: {}
    }
    connectionProtocol: 'IKEv2'
    connectionMode: 'Default'
    sharedKey: replace(tenant().tenantId, '-', '')
    enableBgp: false
    useLocalAzureIpAddress: false
  }
}
