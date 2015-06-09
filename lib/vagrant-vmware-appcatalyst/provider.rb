require 'log4r'
require 'vagrant'

module VagrantPlugins
  module AppCatalyst
    class Provider < Vagrant.plugin('2', :provider)
      def initialize(machine)
        @logger  = Log4r::Logger.new("vagrant::provider::vmware_appcatalyst")
        @machine = machine
      end

      def action(name)
        action_method = "action_#{name}"
        return Action.send(action_method) if Action.respond_to?(action_method)
        nil
      end

      def ssh_info
        env = @machine.action('read_ssh_info')
        env[:machine_ssh_info]
      end

      def state
        env = @machine.action('read_state')

        state_id = env[:machine_state_id]

        # Translate into short/long descriptions
        short = state_id.to_s.gsub("_", " ")
        long  = I18n.t("vagrant.commands.status.#{state_id}")

        # If we're not created, then specify the special ID flag
        if state_id == :not_created
          state_id = Vagrant::MachineState::NOT_CREATED_ID
        end

        # Return the MachineState object
        Vagrant::MachineState.new(state_id, short, long)
      end

      def to_s
        id = @machine.id.nil? ? 'new' : @machine.id
        "AppCatalyst (#{id})"
      end
    end
  end
end
