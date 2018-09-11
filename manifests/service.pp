# Class: activemq::service
#
#   Manage the ActiveMQ Service
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class activemq::service(
  Enum['running','stopped'] $ensure,
  Boolean                   $service_enable = $::activemq::params::service_enable
) {

  service { 'activemq':
    enable     => $service_enable,
    ensure     => $ensure,
    hasstatus  => true,
    hasrestart => true,
    require    => Class['activemq::packages'],
  }

}
