module VagrantPlugins
  module AppCatalyst
    module Action
      class ConnectAppCatalyst
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new('vagrant_appcatalyst::action::connect_appcatalyst')
        end

        def call(env)
          config = env[:machine].provider_config

          @logger.info('Connecting to AppCatalyst...')

          @logger.debug("config.rest_port: #{config.rest_port}") unless config.rest_port.nil?

          if config.rest_port.nil?
            endpoint = 'http://localhost:8080'
          else
            endpoint = "http://localhost:#{config.rest_port}"
          end

          env[:appcatalyst_cnx] = Driver::Meta.new(endpoint)

          @logger.info('Logging into AppCatalyst...')

          @app.call env
        end
      end
    end
  end
end
