module VagrantPlugins
  module AppCatalyst
    module Action
      class MessageNotSupported
        def initialize(app, env)
          @app = app
        end

        def call(env)
          env[:ui].error(I18n.t('vagrant_appcatalyst.errors.violations.operation_not_supported'))
          @app.call(env)
        end
      end
    end
  end
end
