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
      class ReadSSHInfo
        def initialize(app, env, port = 22)
          @app = app
          @port = port
          @logger = Log4r::Logger.new('vagrant_appcatalyst::action::read_ssh_info')
        end

        def call(env)
          env[:machine_ssh_info] = read_ssh_info(env)

          @app.call env
        end

        def read_ssh_info(env)
          return nil if env[:machine].id.nil?

          begin
            ipaddress = env[:appcatalyst_cnx].get_vm_ipaddress(env[:machine].id)
          rescue Errors::UnattendedCodeError
            @retries ||= 0
            if @retries < 60
              @retries += 1
              sleep 2
              retry
            else
              raise Errors::UnattendedCodeError,
                    :message => "Can't look up ip address for this VM"
            end
          end

          # If we are here, then SSH is ready, continue
          {
            :host => ipaddress['message'],
            :port => 22
          }
        end
      end
    end
  end
end
