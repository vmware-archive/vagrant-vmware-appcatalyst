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

require 'log4r'
require 'vagrant/util/busy'
require 'vagrant/util/platform'
require 'vagrant/util/retryable'
require 'vagrant/util/subprocess'

module VagrantPlugins
  module AppCatalyst
    module Driver
      # Main class to access AppCatalyst rest APIs
      class Base
        include Vagrant::Util::Retryable

        def initialize
          @logger = Log4r::Logger.new('vagrant::provider::appcatalyst::base')
          @interrupted = false
        end

        # Fetch details about a given VM
        def get_vm(vm_id)
        end

        def get_vm_power(vm_id)
        end

        def get_vm_ipaddress(vm_id)
        end

        def set_vm_power(vm_id, operation)
        end

        def delete_vm(vm_id)
        end

        def import_vm(vm_id, name, source_reference, tag)
        end

        def list_vms
        end

        def get_vm_shared_folders(vm_id)
        end

        def set_vm_shared_folders(vm_id, operation)
        end

        def add_vm_shared_folder(vm_id, guest_path, host_path, flags)
        end

        def get_vm_shared_folder(vm_id, shared_folder_id)
        end

        def delete_vm_shared_folder(vm_id, shared_folder_id)
        end

        def clone_vm_in_directory(src, dest)
        end

        def set_vmx_value(vmx_file, key, value)
        end

        private

        ##
        # Sends a synchronous request to the AppCatalyst API and returns the
        # response as parsed XML + headers using HTTPClient.
        def send_request(params, payload = nil, content_type = nil)
          # Create a new HTTP client
          clnt = HTTPClient.new

          extheader = {}
          extheader['accept'] = "application/json"
          extheader['Content-Type'] = content_type unless content_type.nil?

          url = "#{@endpoint}#{params['command']}"

          @logger.debug("[#{Time.now.ctime}] -> SEND #{params['method'].upcase} #{url}")
          if payload
            @logger.debug('SEND HEADERS')
            @logger.debug(extheader)
            @logger.debug('SEND BODY')
            @logger.debug(payload)
          end

          begin
            response = clnt.request(
              params['method'],
              url,
              nil,
              payload,
              extheader
            )

            @logger.debug("[#{Time.now.ctime}] <- RECV #{response.status}")
            @logger.debug('RECV HEADERS')
            @logger.debug(response.headers)
            @logger.debug('RECV BODY') if response.body.length > 0
            @logger.debug(response.body) if response.body.length > 0

            unless response.ok?
              error_response = JSON.parse(response.body)
              fail Errors::UnattendedCodeError,
                   :message => "#{error_response['code']}: #{error_response['message']}"
            end

            if response.body.length > 0
              [JSON.parse(response.body), response.headers]
            else
              ['', response.headers]
            end
          rescue SocketError, Errno::EADDRNOTAVAIL, Errno::ETIMEDOUT, Errno::ECONNREFUSED
            raise Errors::EndpointUnavailable
          end
        end
      end # class
    end
  end
end
