require 'vagrant/util/scoped_hash_override'

module VagrantPlugins
  module AppCatalyst
    module Util
      module CompileForwardedPorts
        include Vagrant::Util::ScopedHashOverride

        # This method compiles the forwarded ports into {ForwardedPort}
        # models.
        def compile_forwarded_ports(config)
          mappings = {}

          config.vm.networks.each do |type, options|
            if type == :forwarded_port
              guest_port = options[:guest]
              host_port  = options[:host]
              options    = scoped_hash_override(options, :vcloud)
              id         = options[:id]

              # skip forwarded rules already found in handle_nat_port_collisions
              next if options[:already_exists]

              mappings[host_port] =
                Model::ForwardedPort.new(id, host_port, guest_port, options)
            end
          end

          mappings.values
        end
      end
    end
  end
end
