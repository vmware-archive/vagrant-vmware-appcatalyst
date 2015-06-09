require 'securerandom'

module VagrantPlugins
  module AppCatalyst
    module Action
      class Import
        def initialize(app, _env)
          @app = app
          @logger = Log4r::Logger.new('vagrant_appcatalyst::action::import')
        end

        def call(env)
          env[:ui].info I18n.t('vagrant.actions.vm.import.importing',
                               name: env[:machine].box.name)

          # Generate a random UUID for our box
          uuid = "vagrant-#{SecureRandom.uuid}"

          env[:ui].detail I18n.t('vagrant_appcatalyst.vm.cloning')

          env[:appcatalyst_cnx].clone_vm_in_directory(
            env[:machine].box.directory,
            "#{env[:machine].data_dir}/#{uuid}"
          )

          vmx_file = Dir.glob(
            "#{env[:machine].data_dir}/#{uuid}/*.vmx"
          ).first

          # Make sure we use Virtual HW 11
          env[:appcatalyst_cnx].set_vmx_value(vmx_file, 'virtualHW.version', '11')

          # Make sure we use VGA only...
          env[:appcatalyst_cnx].set_vmx_value(vmx_file, 'svga.vgaOnly', 'true')

          # Reconfigure VM with additional parameters specified in the
          # Vagrantfile.
          unless env[:machine].provider_config.vmx.empty?
            @logger.debug(
              "Adding parameters to VMX: #{env[:machine].provider_config.vmx}"
            )
            env[:machine].provider_config.vmx.each do |k, v|
              env[:appcatalyst_cnx].set_vmx_value(vmx_file, k, v)
            end
          end

          env[:appcatalyst_cnx].import_vm(
            uuid,
            "Vagrant: #{env[:machine].name}",
            vmx_file,
            'vagrant'
          )

          # If import has succeded, let's set machine id.
          env[:machine].id = uuid

          # If we got interrupted, then the import could have been
          # interrupted and its not a big deal. Just return out.
          return if env[:interrupted]

          # Flag as erroneous and return if import failed
          # TODO: raise correct error
          fail Vagrant::Errors::VMImportFailure unless env[:machine].id

          # Import completed successfully. Continue the chain
          @app.call(env)
        end

        def recover(env)
          if env[:machine].state.id != :not_created
            return if env['vagrant.error'].is_a?(Vagrant::Errors::VagrantError)

            # If we're not supposed to destroy on error then just return
            return unless env[:destroy_on_error]

            # Interrupted, destroy the VM. We note that we don't want to
            # validate the configuration here, and we don't want to confirm
            # we want to destroy.
            destroy_env = env.clone
            destroy_env[:config_validate] = false
            destroy_env[:force_confirm_destroy] = true
            env[:action_runner].run(Action.action_destroy, destroy_env)
          end
        end
      end
    end
  end
end
