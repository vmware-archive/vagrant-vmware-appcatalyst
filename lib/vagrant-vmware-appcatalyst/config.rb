require 'vagrant'

module VagrantPlugins
  module AppCatalyst
    class Config < Vagrant.plugin('2', :config)
      # login attributes

      # Add extra configuration K/V pairs to VMX
      #
      # @return [Hash]
      attr_accessor :vmx

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
