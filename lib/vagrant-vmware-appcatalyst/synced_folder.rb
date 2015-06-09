require "vagrant/util/platform"

module VagrantPlugins
  module AppCatalyst
    class SyncedFolder < Vagrant.plugin("2", :synced_folder)
      def usable?(machine, raise_errors=false)
        return false if machine.provider_name != :vmware_appcatalyst

        machine.provider_config.functional_hgfs
      end

      def prepare(machine, folders, _opts)
        @machine = machine
        share_folders(machine, folders, false)
      end

      def enable(machine, folders, _opts)
        share_folders(machine, folders, true)

        # short guestpaths first, so we don't step on ourselves
        folders = folders.sort_by do |id, data|
          if data[:guestpath]
            data[:guestpath].length
          else
            # A long enough path to just do this at the end.
            10000
          end
        end

        # Go through each folder and mount
        machine.ui.output(I18n.t("vagrant.actions.vm.share_folders.mounting"))
        folders.each do |id, data|
          if data[:guestpath]
            # Guest path specified, so mount the folder to specified point
            machine.ui.detail(I18n.t("vagrant.actions.vm.share_folders.mounting_entry",
                                  guestpath: data[:guestpath],
                                  hostpath: data[:hostpath]))

            # Dup the data so we can pass it to the guest API
            data = data.dup

            # Calculate the owner and group
            ssh_info = machine.ssh_info
            data[:owner] ||= ssh_info[:username]
            data[:group] ||= ssh_info[:username]

            # Mount the actual folder
            machine.guest.capability(
              :mount_appcatalyst_shared_folder,
              os_friendly_id(id), data[:guestpath], data)
          else
            # If no guest path is specified, then automounting is disabled
            machine.ui.detail(I18n.t("vagrant.actions.vm.share_folders.nomount_entry",
                                  hostpath: data[:hostpath]))
          end
        end
      end

      def disable(machine, folders, _opts)
        if machine.guest.capability?(:unmount_appcatalyst_shared_folder)
          folders.each do |id, data|
            machine.guest.capability(
              :unmount_appcatalyst_shared_folder,
              data[:guestpath], data)
          end
        end

        # Remove the shared folders from the VM metadata
        names = folders.map { |id, _data| os_friendly_id(id) }
        env = @machine.action('connect')
        names.each do |name|
          env[:appcatalyst_cnx].delete_vm_shared_folder(env[:machine].id, name)
        end
      end

      def cleanup(machine, opts)
        @machine = machine
        env = @machine.action('connect')

        if machine.id && machine.id != ""
          env[:appcatalyst_cnx].get_vm_shared_folders(env[:machine].id).each do |folder|
            env[:appcatalyst_cnx].delete_vm_shared_folder(env[:machine].id, folder)
          end
        end
      end

      protected

      def os_friendly_id(id)
        id.gsub(/[\/]/,'_').sub(/^_/, '')
      end

      # share_folders sets up the shared folder definitions on the
      # VirtualBox VM.
      #
      # The transient parameter determines if we're FORCING transient
      # or not. If this is false, then any shared folders will be
      # shared as non-transient unless they've specifically asked for
      # transient.
      def share_folders(machine, folders, transient)
        env = @machine.action('connect')

        defs = []
        folders.each do |id, data|
          hostpath = data[:hostpath]
          if !data[:hostpath_exact]
            hostpath = Vagrant::Util::Platform.cygwin_windows_path(hostpath)
          end

          # Only setup the shared folders that match our transient level
          if (!!data[:transient]) == transient
            defs << {
              name: os_friendly_id(id),
              hostpath: hostpath.to_s,
              transient: transient,
            }
          end
        end
        # Enable shared folders
        env[:appcatalyst_cnx].set_vm_shared_folders(env[:machine].id, 'true')
        # driver(machine).share_folders(defs)
        defs.each do |folder|
          env[:appcatalyst_cnx].add_vm_shared_folder(env[:machine].id, folder[:name], folder[:hostpath], 4)
        end
      end
    end
  end
end
