module VagrantPlugins
  module AppCatalyst
    module Action
      class Resume
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new('vagrant_appcatalyst::action::resume')
        end

        def call(env)
          env[:appcatalyst_cnx].set_vm_power(env[:machine].id, 'resume')

          @app.call(env)
        end
      end
    end
  end
end
