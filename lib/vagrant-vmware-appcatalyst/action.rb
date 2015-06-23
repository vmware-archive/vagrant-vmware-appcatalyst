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

require 'pathname'
require 'vagrant/action/builder'

module VagrantPlugins
  module AppCatalyst
    # This module dictates the actions to be performed by Vagrant when called
    # with a specific command
    module Action
      include Vagrant::Action::Builtin

      # Vagrant commands
      # This action boots the VM, assuming the VM is in a state that requires
      # a bootup (i.e. not saved).
      def self.action_boot
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use PowerOn
          b.use WaitForCommunicator, [:starting, :running]
          b.use Provision
          b.use SetHostname
          b.use SyncedFolderCleanup
          b.use SyncedFolders
        end
      end

      def self.action_reload
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            unless env[:result]
              b2.use MessageNotCreated
              next
            end
            b2.use action_halt
            b2.use action_start
          end
        end
      end

      # This action starts a VM, assuming it is already imported and exists.
      # A precondition of this action is that the VM exists.
      def self.action_start
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConnectAppCatalyst
          b.use ConfigValidate
          b.use BoxCheckOutdated
          b.use Call, IsRunning do |env, b2|
            # If the VM is running, then our work here is done, exit
            if env[:result]
              b2.use MessageAlreadyRunning
              next
            end

            b2.use action_boot
          end
        end
      end

      def self.action_halt
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectAppCatalyst
          b.use PowerOff
        end
      end

      def self.action_suspend
        Vagrant::Action::Builder.new.tap do |b|
          b.use MessageNotSupported
        end
      end

      def self.action_resume
        Vagrant::Action::Builder.new.tap do |b|
          b.use MessageNotSupported
        end
      end

      def self.action_destroy
        Vagrant::Action::Builder.new.tap do |b|
          b.use Call, DestroyConfirm do |env, b2|
            if env[:result]
              b2.use ConfigValidate
              b2.use ConnectAppCatalyst
              b2.use Call, IsCreated do |env2, b3|
                unless env2[:result]
                  b3.use MessageNotCreated
                  next
                end
                b3.use ProvisionerCleanup
                b3.use Call, IsRunning do |env3, b4|
                  # If the VM is running, must power off
                  b4.use action_halt if env3[:result]
                end
                b3.use DestroyVM
              end
            else
              b2.use MessageWillNotDestroy
            end
          end
        end
      end

      def self.action_provision
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            unless env[:result]
              b2.use MessageNotCreated
              next
            end
            b2.use Call, IsRunning do |env2, b3|
              unless env2[:result]
                b3.use MessageNotRunning
                next
              end
              b3.use Provision
            end
          end
        end
      end

      # This action is called to read the SSH info of the machine. The
      # resulting state is expected to be put into the `:machine_ssh_info`
      # key.
      def self.action_read_ssh_info
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConnectAppCatalyst
          b.use ReadSSHInfo, 22
        end
      end

      # This action is called to read the state of the machine. The
      # resulting state is expected to be put into the `:machine_state_id`
      # key.
      def self.action_read_state
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectAppCatalyst
          b.use ReadState
        end
      end

      def self.action_ssh
        Vagrant::Action::Builder.new.tap do |b|
          # b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            unless env[:result]
              b2.use MessageNotCreated
              next
            end

            b2.use Call, IsRunning do |env2, b3|
              unless env2[:result]
                b3.use MessageNotRunning
                next
              end
              b3.use SSHExec
            end
          end
        end
      end

      def self.action_ssh_run
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            unless env[:result]
              b2.use MessageNotCreated
              next
            end

            b2.use SSHRun
          end
        end
      end

      def self.action_up
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConnectAppCatalyst

          b.use Call, IsCreated do |env, b2|
            b2.use HandleBox unless env[:result]
          end

          b.use ConfigValidate

          b.use Call, IsCreated do |env, b2|
            unless env[:result]
              b2.use Import
            end
          end
          b.use action_start
        end
      end

      def self.action_connect
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConnectAppCatalyst
        end
      end


      # The autoload farm
      action_root = Pathname.new(File.expand_path('../action', __FILE__))
      autoload :Import,
               action_root.join('import')
      autoload :ConnectAppCatalyst,
               action_root.join('connect_appcatalyst')
      autoload :DestroyVM,
               action_root.join('destroy_vm')
      autoload :IsCreated,
               action_root.join('is_created')
      autoload :IsRunning,
               action_root.join('is_running')
      autoload :MessageAlreadyRunning,
               action_root.join('message_already_running')
      autoload :MessageNotRunning,
               action_root.join('message_not_running')
      autoload :MessageNotCreated,
               action_root.join('message_not_created')
     autoload :MessageNotSupported,
               action_root.join('message_not_supported')
      autoload :MessageWillNotDestroy,
               action_root.join('message_will_not_destroy')
      autoload :PowerOff,
               action_root.join('power_off')
      autoload :PowerOn,
               action_root.join('power_on')
      autoload :ReadSSHInfo,
               action_root.join('read_ssh_info')
      autoload :ReadState,
               action_root.join('read_state')
    end
  end
end
