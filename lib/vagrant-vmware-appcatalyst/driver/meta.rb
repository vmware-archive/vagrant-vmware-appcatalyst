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

require 'forwardable'
require 'log4r'
require 'httpclient'
require 'json'

require File.expand_path('../base', __FILE__)

module VagrantPlugins
  module AppCatalyst
    module Driver
      class Meta < Base
        extend Forwardable
        attr_reader :endpoint
        attr_reader :version

        def initialize(endpoint)
          super()

          @logger = Log4r::Logger.new('vagrant::provider::appcatalyst::meta')

          @endpoint = endpoint

          # Read and assign the version of AppCatalyst we know which
          # specific driver to instantiate.
          @logger.debug("Asking API Version with host_url: #{@endpoint}")
          @version = get_api_version(@endpoint) || ''

          # Instantiate the proper version driver for AppCatalyst
          @logger.debug("Finding driver for AppCatalyst version: #{@version}")
          driver_map   = {
            '1.0.0' => Version_1_0
          }

          driver_klass = nil
          driver_map.each do |key, klass|
            if @version.start_with?(key)
              driver_klass = klass
              break
            end
          end

          unless driver_klass
            supported_versions = driver_map.keys.sort.join(', ')
            fail Errors::AppCatalystInvalidVersion,
                 :supported_versions => supported_versions
          end

          @logger.info("Using AppCatalyst driver: #{driver_klass}")
          @driver = driver_klass.new(@endpoint)
        end

        def_delegators :@driver,
                       :get_vm,
                       :get_vm_power,
                       :get_vm_ipaddress,
                       :set_vm_power,
                       :delete_vm,
                       :import_vm,
                       :list_vm,
                       :get_vm_shared_folders,
                       :set_vm_shared_folders,
                       :add_vm_shared_folder,
                       :get_vm_shared_folder,
                       :delete_vm_shared_folder,
                       :clone_vm_in_directory,
                       :set_vmx_value
        protected

        def get_api_version(endpoint)
          # Create a new HTTP client
          clnt = HTTPClient.new
          uri = URI(endpoint)
          url = "#{uri.scheme}://#{uri.host}:#{uri.port}/json/swagger.json"

          begin
            response = clnt.request('GET', url, nil, nil, nil)
            unless response.ok?
              fail Errors::UnattendedCodeError,
                   :message => "#{response.status} #{response.reason}"
            end

            api_definition = JSON.parse(response.body)

            api_definition['info']['version']

          rescue SocketError, Errno::EADDRNOTAVAIL, Errno::ETIMEDOUT, Errno::ECONNREFUSED
            raise Errors::EndpointUnavailable
          end
        end
      end
    end
  end
end
