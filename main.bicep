targetScope = 'subscription'

@minLength(2)
@maxLength(2)
param sites array

param deploymentName string = '${deployment().name}-${uniqueString(utcNow())}'

param bastionScaleUnits int = 2

param jumphostSshKeyData string
param jumphostVmSize string = 'Standard_D2d_v5'
param jumphostImagePublisher string = 'Canonical'
param jumphostImageOffer string = '0001-com-ubuntu-server-jammy'
param jumphostImageSku string = '22_04-lts-gen2'
param jumphostImageVersion string = 'latest'
param jumphostDiskSizeGB int = 64

module siteModule 'modules/site.bicep' = [for site in sites: {
  name: '${deploymentName}-${site.name}'
  scope: subscription(site.subscriptionId)
  params: {
    name: site.name
    environment: site.environment
    region: site.region
    location: site.location
    deploymentName: '${deploymentName}-${site.name}'
    networkAddressPrefix: site.networkAddressPrefix
    bastionScaleUnits: bastionScaleUnits
    jumphostSshKeyData: jumphostSshKeyData
    jumphostVmSize: jumphostVmSize
    jumphostImagePublisher: jumphostImagePublisher
    jumphostImageOffer: jumphostImageOffer
    jumphostImageSku: jumphostImageSku
    jumphostImageVersion: jumphostImageVersion
    jumphostDiskSizeGB: jumphostDiskSizeGB
  }
}]

module vpn 'modules/vpn.bicep' = [for (site, index) in sites: {
  name: '${deploymentName}-${site.name}-vpn'
  scope: subscription(site.subscriptionId)
  params: {
    resourceGroupName: siteModule[index].outputs.resourceGroupName
    resourceSuffix: siteModule[index].outputs.resourceSuffix
    location: site.location
    gatewayIpAddress: siteModule[(index + 1) % length(sites)].outputs.gatewayIpAddress
    deploymentName: '${deploymentName}-${site.name}'
    localNetworkAddressPrefix: sites[(index + 1) % length(sites)].networkAddressPrefix
    virtualNetworkGatewayId: siteModule[index].outputs.virtualNetworkGatewayId
  }
}]

output commands array = [for (site, index) in sites: 'az network bastion ssh --name ${siteModule[index].outputs.bastionName} --resource-group ${siteModule[index].outputs.resourceGroupName} --auth-type ssh-key --username azure --target-resource-id ${siteModule[index].outputs.jumphostId} --ssh-key ...']
