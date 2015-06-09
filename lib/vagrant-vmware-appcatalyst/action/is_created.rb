module VagrantPlugins
  module AppCatalyst
    module Action
      class IsCreated
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new('vagrant_appcatalyst::action::is_created')
        end

        def call(env)
          # Set the result to be true if the machine is created.
          env[:result] = env[:machine].state.id != :not_created

          # Call the next if we have one (but we shouldn't, since this
          # middleware is built to run with the Call-type middlewares)
          @app.call(env)
        end
      end
    end
  end
end
