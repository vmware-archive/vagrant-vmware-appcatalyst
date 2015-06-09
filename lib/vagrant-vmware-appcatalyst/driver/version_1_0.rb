# encoding: UTF-8
require 'uri'
require 'vagrant/util/platform'
require 'log4r'

module VagrantPlugins
  module AppCatalyst
    module Driver
      # Main class to access AppCatalyst rest APIs
      class Version_1_0 < Base

        ##
        # Init the driver with the Vagrantfile information
        def initialize(endpoint)
          super()

          @logger = Log4r::Logger.new('vagrant::provider::appcatalyst::driver_1_0')
          @logger.debug("AppCatalyst Driver 1.0 loaded")
          @endpoint = endpoint
        end

        ##
        # Fetch details about a given VM
        def get_vm(vm_id)
          params = {
            'method'  => :get,
            'command' => "/api/vms/#{vm_id}"
          }

          response, _headers = send_request(params)

          response
        end

        def get_vm_power(vm_id)
          params = {
            'method'  => :get,
            'command' => "/api/vms/power/#{vm_id}"
          }

          response, _headers = send_request(params)

          response
        end

        def get_vm_ipaddress(vm_id)
          params = {
            'method'  => :get,
            'command' => "/api/vms/#{vm_id}/ipaddress"
          }

          response, _headers = send_request(params)

          response
        end

        def set_vm_power(vm_id, operation)
          params = {
            'method'  => :patch,
            'command' => "/api/vms/power/#{vm_id}"
          }

          response, _headers = send_request(
            params,
            operation,
            'application/json'
          )

          response
        end

        def delete_vm(vm_id)
          params = {
            'method'  => :delete,
            'command' => "/api/vms/#{vm_id}"
          }

          _response, _headers = send_request(params)
        end

        def import_vm(vm_id, name, source_reference, tag)
          @logger.debug("Importing #{name}")
          vm_to_import = {
            'id' => vm_id,
            'name' => name,
            'sourceReference' => source_reference,
            'tag' => tag
          }

          params = {
            'method'  => :post,
            'command' => '/api/vms'
          }

          @logger.debug("JSON stuff #{JSON.generate(vm_to_import)}")
          response, _headers = send_request(
            params,
            JSON.generate(vm_to_import),
            'application/json'
          )

          response
        end

        def list_vms
          params = {
            'method'  => :get,
            'command' => '/api/vms'
          }

          response, _headers = send_request(params)

          response
        end

        def get_vm_shared_folders(vm_id)
          params = {
            'method'  => :get,
            'command' => "/api/vms/#{vm_id}/folders"
          }

          response, _headers = send_request(params)

          response
        end

        def set_vm_shared_folders(vm_id, operation)
          params = {
            'method'  => :patch,
            'command' => "/api/vms/#{vm_id}/folders"
          }

          response, _headers = send_request(
            params,
            operation,
            'application/json'
          )

          response
        end

        def add_vm_shared_folder(vm_id, guest_path, host_path, flags)
          @logger.debug("Adding Shared Folder #{guest_path} to #{vm_id}")
          shared_folder_to_add = {
            'guestPath' => guest_path,
            'hostPath' => host_path,
            'flags' => flags
          }

          params = {
            'method'  => :post,
            'command' => "/api/vms/#{vm_id}/folders"
          }

          @logger.debug("JSON stuff #{JSON.generate(shared_folder_to_add)}")
          response, _headers = send_request(
            params,
            JSON.generate(shared_folder_to_add),
            'application/json'
          )

          response
        end

        def get_vm_shared_folder(vm_id, shared_folder_id)
          params = {
            'method'  => :get,
            'command' => "/api/vms/#{vm_id}/folders/#{shared_folder_id}"
          }

          response, _headers = send_request(params)

          response
        end

        def delete_vm_shared_folder(vm_id, shared_folder_id)
          params = {
            'method'  => :delete,
            'command' => "/api/vms/#{vm_id}/folders/#{shared_folder_id}"
          }

          _response, _headers = send_request(params)
        end

        def clone_vm_in_directory(src, dest)
          @logger.debug("Cloning VM from #{src} to #{dest}")
          FileUtils.cp_r("#{src}/.", dest)
        end

        def set_vmx_value(vmx_file, key, value)
          # read VMX in a hash
          temp_vmx = Hash[File.read(vmx_file).scan(/^(.+?)\s*=\s*"(.*?)"\s*$/)]
          vmx = Hash[temp_vmx.map { |k, v| v.class == Array ? [k, v.map { |r| f r }.to_a] : [k.downcase, v]}]
          @logger.debug("Setting #{key} = #{value} in VMX")
          # Set the key/value
          vmx[key.downcase] = value

          # Open file for writing
          f = File.open(vmx_file, 'w')

          # Write file in order
          vmx.sort.map do |k, v|
            f.write("#{k} = \"#{v}\"\n")
          end

          f.close
        end
      end # Class Version 5.1
    end # Module Driver
  end # module AppCatalyst
end # Module VagrantPlugins
