# Class: wsusserver::service
#
#
class wsusserver::service(
  Boolean $service_manage                            = $wsusserver::params::service_manage,
  Enum['running', 'stopped'] $service_ensure         = $wsusserver::params::service_ensure,
  Variant[ Boolean, Enum['manual'] ] $service_enable = $wsusserver::params::service_enable,
) inherits wsusserver::params {

  if $service_manage {
    service { 'wsusservice':
      ensure => $service_ensure,
      enable => $service_enable,
    }
  }
}
