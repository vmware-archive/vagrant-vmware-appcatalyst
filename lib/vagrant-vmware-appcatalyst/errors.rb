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
