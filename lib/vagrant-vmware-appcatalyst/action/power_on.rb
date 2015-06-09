module VagrantPlugins
  module AppCatalyst
    module Action
      class PowerOn
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new('vagrant_appcatalyst::action::power_on')
        end

        def call(env)
          begin
            env[:appcatalyst_cnx].set_vm_power(env[:machine].id, 'on')
          rescue Errors::UnattendedCodeError
            raise Errors::PowerOnNotAllowed
          end
          @app.call(env)
        end
      end
    end
  end
end
