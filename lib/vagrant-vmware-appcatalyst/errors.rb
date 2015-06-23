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

require 'vagrant'

module VagrantPlugins
  module AppCatalyst
    module Errors
      # Generic Errors during Vagrant execution
      class AppCatalystGenericError < Vagrant::Errors::VagrantError
        error_namespace('vagrant_appcatalyst.errors')
      end
      class AppCatalystOldVersion < AppCatalystGenericError
        error_key(:appcatalyst_old_version)
      end
      # Errors in the REST API communication
      class AppCatalystRestError < Vagrant::Errors::VagrantError
        error_namespace('vagrant_appcatalyst.errors.rest_errors')
      end
      class UnattendedCodeError < AppCatalystRestError
        error_key(:unattended_code_error)
      end
      class EndpointUnavailable < AppCatalystRestError
        error_key(:endpoint_unavailable)
      end
      class AppCatalystViolationError < Vagrant::Errors::VagrantError
        error_namespace('vagrant_appcatalyst.errors.violations')
      end
      class PowerOnNotAllowed < AppCatalystViolationError
        error_key(:poweron_not_allowed)
      end
    end
  end
end
