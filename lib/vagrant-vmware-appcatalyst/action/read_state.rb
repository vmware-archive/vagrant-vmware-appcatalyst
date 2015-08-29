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

module VagrantPlugins
  module AppCatalyst
    module Action
      class ReadState
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new('vagrant_appcatalyst::action::read_state')
        end

        def call(env)
          env[:machine_state_id] = read_state(env)

          @app.call env
        end

        def read_state(env)
          vm_name = env[:machine].name

          if env[:machine].id.nil?
            @logger.info("VM [#{vm_name}] is not created yet")
            return :not_created
          end

          power_state = env[:appcatalyst_cnx].get_vm_power(env[:machine].id)

          case power_state['message']
          when 'powering on'
            @logger.info("VM [#{vm_name}] is running")
            return :running
          when 'powered on'
            @logger.info("VM [#{vm_name}] is running")
            return :running
          when 'powering off'
            @logger.info("VM [#{vm_name}] is stopping")
            return :stopping
          when 'powered off'
            @logger.info("VM [#{vm_name}] is stopped")
            return :stopped
          when 'suspended'
            @logger.info("VM [#{vm_name}] is suspended")
            return :suspended
          when 'suspending'
            @logger.info("VM [#{vm_name}] is suspended")
            return :suspending
          when 'tools_running'
            @logger.info("VM [#{vm_name}] is running")
            return :running
          when 'blocked on msg'
            @logger.info("VM [#{vm_name}] is stopped")
            return :blocked
          else
            @logger.info("VM [#{vm_name}] is in an unknown state")
            return :unknown
          end
        end
      end
    end
  end
end
