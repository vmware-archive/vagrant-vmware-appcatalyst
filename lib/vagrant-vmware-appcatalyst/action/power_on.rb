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
      class PowerOn
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new('vagrant_appcatalyst::action::power_on')
        end

        def call(env)
          begin
            env[:appcatalyst_cnx].set_vm_power(env[:machine].id, 'on')
          rescue Errors::UnattendedCodeError
            raise Errors::PowerOnNotAllowed
          end
          @app.call(env)
        end
      end
    end
  end
end
