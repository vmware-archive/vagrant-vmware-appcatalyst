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
      class Resume
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new('vagrant_appcatalyst::action::resume')
        end

        def call(env)
          current_state = env[:machine].state.id

          if current_state == :paused
            env[:ui].info I18n.t('vagrant.actions.vm.resume.unpausing')
            env[:appcatalyst_cnx].set_vm_power(env[:machine].id, 'unpause')
          elsif current_state == :suspended
            env[:ui].info I18n.t('vagrant.actions.vm.resume.resuming')
            env[:appcatalyst_cnx].set_vm_power(env[:machine].id, 'on')
          end
          @app.call(env)
        end
      end
    end
  end
end
