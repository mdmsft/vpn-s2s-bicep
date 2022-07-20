param resourceSuffix string
param location string = resourceGroup().location
param subnetId string
param publicIpPrefixId string

resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
  name: 'pip-${resourceSuffix}-vgw'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    publicIPPrefix: {
      id: publicIpPrefixId
    }
  }
}

resource gateway 'Microsoft.Network/virtualNetworkGateways@2022-01-01' = {
  name: 'vgw-${resourceSuffix}'
  location: location
  properties: {
    activeActive: false
    enableBgp: false
    gatewayType: 'Vpn'
    ipConfigurations: [
      {
        name: 'default'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIpAddress.id
          }
          subnet: {
            id: subnetId
          }
        }
      }
    ]
    sku: {
      name: 'VpnGw2'
      tier: 'VpnGw2'
    }
    vpnGatewayGeneration: 'Generation2'
    vpnType: 'RouteBased'
  }
}

output id string = gateway.id
output ipAddress string = publicIpAddress.properties.ipAddress
