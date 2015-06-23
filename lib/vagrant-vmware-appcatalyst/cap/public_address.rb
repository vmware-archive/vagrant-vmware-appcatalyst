# encoding: utf-8
# Copyright (c) 2015 VMware, Inc.  All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License.  You may obtain a copy of
# the License at http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, without
# warranties or conditions of any kind, EITHER EXPRESS OR IMPLIED.  See the
# License for the specific language governing permissions and limitations under
# the License.

module VagrantPlugins
  module AppCatalyst
    module Cap
      module PublicAddress
        def self.public_address(machine)
          # Initial try for vagrant share feature.
          # It seems ssh_info[:port] is given automatically.
          # I think this feature was built planning that the port forwarding
          # and networking was done on the vagrant machine, which isn't the
          # case in vagrant-vmware-appcatalyst

          ssh_info = machine.ssh_info
          ssh_info[:host]
        end
      end
    end
  end
end
