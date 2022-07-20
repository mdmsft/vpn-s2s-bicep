param subnetId string
param adminUsername string
param resourceSuffix string
param sshKeyData string
param location string = resourceGroup().location
param vmSize string
param imagePublisher string
param imageOffer string
param imageSku string
param imageVersion string
param diskSizeGB int

resource networkInterface 'Microsoft.Network/networkInterfaces@2021-03-01' = {
  name: 'nic-${resourceSuffix}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'default'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: 'vm-${resourceSuffix}'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: resourceSuffix
      adminUsername: adminUsername
      linuxConfiguration: {
        disablePasswordAuthentication: true
        patchSettings: {
          patchMode: 'ImageDefault'
        }
        provisionVMAgent: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${adminUsername}/.ssh/authorized_keys'
              keyData: base64ToString(sshKeyData)
            }
          ]
        }
      }
    }
    storageProfile: {
      imageReference: {
        publisher: imagePublisher
        offer: imageOffer
        sku: imageSku
        version: imageVersion
      }
      osDisk: {
        name: 'osdisk-${resourceSuffix}'
        caching: 'ReadOnly'
        diffDiskSettings: {
          option: 'Local'
          placement: 'ResourceDisk'
        }
        diskSizeGB: diskSizeGB
        osType: 'Linux'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
        }
      ]
    }
  }
}

output id string = virtualMachine.id
