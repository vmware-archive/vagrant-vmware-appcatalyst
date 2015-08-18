[Vagrant](http://www.vagrantup.com) provider for [VMware AppCatalyst®](https://communities.vmware.com/community/vmtn/devops/vmware-appcatalyst) [![Gem Version](https://badge.fury.io/rb/vagrant-vmware-appcatalyst.svg)](http://badge.fury.io/rb/vagrant-vmware-appcatalyst) [![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/vmware/vagrant-vmware-appcatalyst?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)
=============

This plugin supports `vmware_desktop`, `vmware_fusion` and `vmware_workstation` box type, the same used by Hashicorp plugins for VMware products.

Install
-------------

Latest version can be easily installed by running the following command:

```vagrant plugin install vagrant-vmware-appcatalyst```

Vagrant will download all the required gems during the installation process.

After the install has completed a ```vagrant up --provider=vmware_appcatalyst``` will trigger the newly installed provider.

*Note: The AppCatalyst Daemon must be running before bringing up a new vagrant box:*
```appcatalyst-daemon start```

Upgrade
-------------

If you already have vagrant-vmware-appcatalyst installed you can update to the latest version available by issuing:

```vagrant plugin update vagrant-vmware-appcatalyst```

Vagrant will take care of the upgrade process.

Configuration
-------------

Here's a sample Vagrantfile that builds a docker host on AppCatalyst and starts a Wordpress container on port 80, make sure you replace the placeholders with your own values.

```ruby
# Set our default provider for this Vagrantfile to 'vmware_appcatalyst'
ENV['VAGRANT_DEFAULT_PROVIDER'] = 'vmware_appcatalyst'

nodes = [
  { hostname: 'gantry-test-1', box: 'hashicorp/precise64' },
  { hostname: 'gantry-test-2', box: 'hashicorp/precise64' }
]

Vagrant.configure('2') do |config|

  # Configure our boxes with 1 CPU and 384MB of RAM
  config.vm.provider 'vmware_appcatalyst' do |v|
    v.cpus = '1'
    v.memory = '384'
  end

  # Go through nodes and configure each of them.j
  nodes.each do |node|
    config.vm.define node[:hostname] do |node_config|
      node_config.vm.box = node[:box]
      node_config.vm.hostname = node[:hostname]
      node_config.vm.synced_folder('/Users/frapposelli/Development', '/development')
    end
  end
end

```

Legal
-----

Copyright © 2015 VMware, Inc.  All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the “License”); you may not
use this file except in compliance with the License.  You may obtain a copy of
the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an “AS IS” BASIS, without warranties or
conditions of any kind, EITHER EXPRESS OR IMPLIED.  See the License for the
specific language governing permissions and limitations under the License.
