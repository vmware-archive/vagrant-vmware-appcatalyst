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

require 'vagrant'

module VagrantPlugins
  module AppCatalyst
    class Config < Vagrant.plugin('2', :config)
      # login attributes

      # Add extra configuration K/V pairs to VMX
      #
      # @return [Hash]
      attr_accessor :vmx

      # Shortcut to set memory in the VM
      #
      # @return [String]
      attr_accessor :memory

      # Shortcut to set cpus in the VM
      #
      # @return [String]
      attr_accessor :cpus

      # REST API daemon port, default 8080
      #
      # @return [String]
      attr_accessor :rest_port

      def initialize
        self.vmx = {}
      end

      def validate(machine)

      end
    end
  end
end
