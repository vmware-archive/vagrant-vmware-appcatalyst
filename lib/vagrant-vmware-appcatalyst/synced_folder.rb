# encoding: utf-8
# Copyright (c) 2015 VMware, Inc.  All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License.  You may obtain a copy of
# the License at http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, without
# warranties or conditions of any kind, EITHER EXPRESS OR IMPLIED.  See the
# License for the specific language governing permissions and limitations under
# the License.

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

        folders = folders.sort_by do |id, data|
          if data[:guestpath]
            data[:guestpath].length
          else
            10_000
          end
        end

        machine.ui.output(I18n.t('vagrant.actions.vm.share_folders.mounting'))
        folders.each do |id, data|
          if data[:guestpath]
            machine.ui.detail(
              I18n.t('vagrant.actions.vm.share_folders.mounting_entry',
                     guestpath: data[:guestpath],
                     hostpath: data[:hostpath]))
            data = data.dup

            ssh_info = machine.ssh_info
            data[:owner] ||= ssh_info[:username]
            data[:group] ||= ssh_info[:username]

            machine.guest.capability(
              :mount_appcatalyst_shared_folder,
              os_friendly_id(id), data[:guestpath], data)
          else
            machine.ui.detail(
              I18n.t('vagrant.actions.vm.share_folders.nomount_entry',
                     hostpath: data[:hostpath]))
          end
        end
      end

      def disable(machine, folders, _opts)
        if machine.guest.capability?(:unmount_appcatalyst_shared_folder)
          folders.each do |_, data|
            machine.guest.capability(
              :unmount_appcatalyst_shared_folder,
              data[:guestpath], data)
          end
        end

        names = folders.map { |id, _| os_friendly_id(id) }
        env = @machine.action('connect')
        names.each do |name|
          env[:appcatalyst_cnx].delete_vm_shared_folder(env[:machine].id, name)
        end
      end

      def cleanup(machine, _)
        @machine = machine
        env = @machine.action('connect')

        if machine.id && machine.id != ''
          env[:appcatalyst_cnx].get_vm_shared_folders(env[:machine].id).each do |folder|
            env[:appcatalyst_cnx].delete_vm_shared_folder(env[:machine].id, folder)
          end
        end
      end

      protected

      def os_friendly_id(id)
        id.gsub(/[\/]/, '_').sub(/^_/, '')
      end

      def share_folders(_, folders, transient)
        env = @machine.action('connect')

        defs = []
        folders.each do |id, data|
          hostpath = data[:hostpath]
          unless data[:hostpath_exact]
            hostpath = Vagrant::Util::Platform.cygwin_windows_path(hostpath)
          end

          if (!!data[:transient]) == transient
            defs << {
              name: os_friendly_id(id),
              hostpath: hostpath.to_s,
              transient: transient,
            }
          end
        end
        env[:appcatalyst_cnx].set_vm_shared_folders(env[:machine].id, 'true')
        defs.each do |folder|
          env[:appcatalyst_cnx].add_vm_shared_folder(env[:machine].id, folder[:name], folder[:hostpath], 4)
        end
      end
    end
  end
end
