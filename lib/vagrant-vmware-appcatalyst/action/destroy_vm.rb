module VagrantPlugins
  module AppCatalyst
    module Action
      class DestroyVM
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new('vagrant_appcatalyst::action::destroy_vm')
        end

        def call(env)
          env[:ui].info I18n.t("vagrant.actions.vm.destroy.destroying")
          env[:appcatalyst_cnx].delete_vm(env[:machine].id)
          env[:machine].id = nil

          @app.call(env)
        end
      end
    end
  end
end
