targetScope = 'subscription'

param name string
param location string = deployment().location
param environment string
param region string
param deploymentName string

param networkAddressPrefix string

param bastionScaleUnits int

param jumphostSshKeyData string
param jumphostVmSize string
param jumphostImagePublisher string
param jumphostImageOffer string
param jumphostImageSku string
param jumphostImageVersion string
param jumphostDiskSizeGB int

var resourceSuffix = '${name}-${environment}-${region}'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${resourceSuffix}'
  location: location
  tags: {
    site: name
    environment: environment
    region: region
    automation: 'bicep'
  }
}

module network './network.bicep' = {
  name: '${deploymentName}-network'
  scope: resourceGroup
  params: {
    location: location
    addressPrefix: networkAddressPrefix
    resourceSuffix: resourceSuffix
  }
}

module bastion './bastion.bicep' = {
  name: '${deploymentName}-bastion'
  scope: resourceGroup
  params: {
    location: location
    subnetId: network.outputs.bastionSubnetId
    scaleUnits: bastionScaleUnits
    resourceSuffix: resourceSuffix
    publicIpPrefixId: network.outputs.publicIpPrefixId
  }
}

module jumphost './jumphost.bicep' = {
  name: '${deploymentName}-jumphost'
  scope: resourceGroup
  params: {
    location: location
    adminUsername: 'azure'
    diskSizeGB: jumphostDiskSizeGB
    imageOffer: jumphostImageOffer
    imagePublisher: jumphostImagePublisher
    imageSku:  jumphostImageSku
    imageVersion: jumphostImageVersion
    sshKeyData: jumphostSshKeyData
    resourceSuffix: resourceSuffix
    subnetId: network.outputs.jumphostSubnetId
    vmSize: jumphostVmSize
  }
}

module gateway 'gateway/virtual.bicep' = {
  scope: resourceGroup
  name: '${deploymentName}-gateway'
  params: {
    publicIpPrefixId: network.outputs.publicIpPrefixId
    resourceSuffix: resourceSuffix
    subnetId: network.outputs.gatewaySubnetId
    location: location
  }
}

output resourceGroupName string = resourceGroup.name
output bastionName string = bastion.outputs.name
output resourceSuffix string = resourceSuffix
output jumphostId string = jumphost.outputs.id
output gatewayIpAddress string = gateway.outputs.ipAddress
output virtualNetworkGatewayId string = gateway.outputs.id
