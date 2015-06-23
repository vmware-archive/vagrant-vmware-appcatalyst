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

begin
  require 'vagrant'
rescue LoadError
  raise 'The Vagrant AppCatalyst plugin must be run within Vagrant.'
end

if Vagrant::VERSION < '1.6.3'
  fail 'The Vagrant AppCatalyst plugin is only compatible with Vagrant 1.6.3+'
end

module VagrantPlugins
  module AppCatalyst
    class Plugin < Vagrant.plugin('2')
      name 'VMware AppCatalyst Provider'
      description 'Allows Vagrant to manage machines with VMware AppCatalyst®'

      config(:vmware_appcatalyst, :provider) do
        require_relative 'config'
        Config
      end

      # We provide support for multiple box formats.
      provider(
        :vmware_appcatalyst,
        box_format: %w(vmware_desktop vmware_fusion vmware_workstation),
        parallel: true
      ) do
        setup_logging
        setup_i18n

        # Return the provider
        require_relative 'provider'
        Provider
      end

      # Add vagrant share support
      provider_capability('vmware_appcatalyst', 'public_address') do
        require_relative 'cap/public_address'
        Cap::PublicAddress
      end

      synced_folder(:vmware_appcatalyst) do
        require File.expand_path('../synced_folder', __FILE__)
        SyncedFolder
      end

      # Add vmware shared folders mount capability to linux
      guest_capability('linux', 'mount_appcatalyst_shared_folder') do
        require_relative 'cap/mount_appcatalyst_shared_folder'
        Cap::MountAppCatalystSharedFolder
      end

      guest_capability('linux', 'unmount_appcatalyst_shared_folder') do
        require_relative 'cap/mount_appcatalyst_shared_folder'
        Cap::MountAppCatalystSharedFolder
      end

      def self.setup_i18n
        I18n.load_path << File.expand_path('locales/en.yml', AppCatalyst.source_root)
        I18n.reload!
      end

      # This sets up our log level to be whatever VAGRANT_LOG is.
      def self.setup_logging
        require 'log4r'

        level = nil
        begin
          level = Log4r.const_get(ENV['VAGRANT_LOG'].upcase)
        rescue NameError
          # This means that the logging constant wasn't found,
          # which is fine. We just keep `level` as `nil`. But
          # we tell the user.
          level = nil
        end

        # Some constants, such as 'true' resolve to booleans, so the
        # above error checking doesn't catch it. This will check to make
        # sure that the log level is an integer, as Log4r requires.
        level = nil unless level.is_a?(Integer)

        # Set the logging level on all 'vagrant' namespaced
        # logs as long as we have a valid level.
        if level
          logger = Log4r::Logger.new('vagrant_appcatalyst')
          logger.outputters = Log4r::Outputter.stderr
          logger.level = level
          # logger = nil
        end
      end
    end

    module Driver
      autoload :Meta, File.expand_path('../driver/meta', __FILE__)
      autoload :Version_1_0, File.expand_path('../driver/version_1_0', __FILE__)
    end
  end
end
