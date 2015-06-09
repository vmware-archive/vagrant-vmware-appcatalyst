module VagrantPlugins
  module AppCatalyst
    module Action
      class Suspend
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new('vagrant_appcatalyst::action::suspend')
        end

        def call(env)
          env[:appcatalyst_cnx].set_vm_power(env[:machine].id, 'suspend')

          @app.call(env)
        end
      end
    end
  end
end
