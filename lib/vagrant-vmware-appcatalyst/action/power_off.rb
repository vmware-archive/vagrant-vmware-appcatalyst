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
      class PowerOff
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new('vagrant_appcatalyst::action::poweroff')
        end

        def call(env)
          current_state = env[:machine].state.id
          if current_state == :running
            env[:ui].info(I18n.t("vagrant.actions.vm.halt.graceful"))
            begin
              env[:appcatalyst_cnx].set_vm_power(env[:machine].id, 'shutdown')
            rescue Errors::UnattendedCodeError
              env[:ui].info I18n.t("vagrant.actions.vm.halt.force")
              env[:appcatalyst_cnx].set_vm_power(env[:machine].id, 'off')
            end
          end

          @app.call(env)
        end
      end
    end
  end
end
