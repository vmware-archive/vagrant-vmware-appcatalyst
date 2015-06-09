module VagrantPlugins
  module AppCatalyst
    module Action
      class PowerOff
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new('vagrant_appcatalyst::action::poweroff')
        end

        def call(env)
          current_state = env[:machine].state.id
          if current_state == :running
            env[:ui].info(I18n.t("vagrant.actions.vm.halt.graceful"))
            begin
              env[:appcatalyst_cnx].set_vm_power(env[:machine].id, 'shutdown')
            rescue Errors::UnattendedCodeError
              env[:ui].info I18n.t("vagrant.actions.vm.halt.force")
              env[:appcatalyst_cnx].set_vm_power(env[:machine].id, 'off')
            end
          end

          @app.call(env)
        end
      end
    end
  end
end
