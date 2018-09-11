# Class: activemq
#
# This module manages the ActiveMQ messaging middleware.
#
# Parameters:
#
# Actions:
#
# Requires:
#
#   Class['java']
#
# Sample Usage:
#
# node default {
#   class { 'activemq': }
# }
#
# To supply your own configuration file:
#
# node default {
#   class { 'activemq':
#     server_config => template('site/activemq.xml.erb'),
#   }
# }
#
class activemq(
  Enum ['present', 'latest', Regexp['^[~+._0-9a-zA-Z:-]+$']]  $version                 = $activemq::params::version,
                                                              $package                 = $activemq::params::package,
  Enum ['running', 'stopped']                                 $ensure                  = $activemq::params::ensure,
                                                              $instance                = $activemq::params::instance,
  Boolean                                                     $webconsole              = $activemq::params::webconsole,
                                                              $server_config           = $activemq::params::server_config,
                                                              $server_config_show_diff = $activemq::params::server_config,
                                                              $mq_broker_name          = $activemq::params::mq_broker_name,
                                                              $mq_admin_username       = $activemq::params::mq_admin_username,
                                                              $mq_admin_password       = $activemq::params::mq_admin_password,
                                                              $mq_cluster_username     = $activemq::params::mq_cluster_username,
                                                              $mq_cluster_password     = $activemq::params::mq_cluster_password,
                                                              $mq_cluster_brokers      = $activemq::params::mq_cluster_brokers,
) inherits activemq::params {

  $mq_admin_username_real       = $mq_admin_username
  $mq_admin_password_real       = $mq_admin_password
  $mq_cluster_username_real     = $mq_cluster_username
  $mq_cluster_password_real     = $mq_cluster_password
  $mq_cluster_brokers_real      = $mq_cluster_brokers

  if $mq_admin_username_real == 'admin' {
    warning '$mq_admin_username is set to the default value.  This should be changed.'
  }

  if $mq_admin_password_real == 'admin' {
    warning '$mq_admin_password is set to the default value.  This should be changed.'
  }

  if size($mq_cluster_brokers_real) > 0 and $mq_cluster_username_real == 'amq' {
    warning '$mq_cluster_username is set to the default value.  This should be changed.'
  }

  if size($mq_cluster_brokers_real) > 0 and $mq_cluster_password_real == 'secret' {
    warning '$mq_cluster_password is set to the default value.  This should be changed.'
  }

  # Since this is a template, it should come _after_ all variables are set for
  # this class.
  $server_config_real = $server_config ? {
    'UNSET' => template("${module_name}/activemq.xml.erb"),
    default => $server_config,
  }

  # Anchors for containing the implementation class
  anchor { 'activemq::begin':
    before => Class['activemq::packages'],
    notify => Class['activemq::service'],
  }

  class { 'activemq::packages':
    version => $version,
    package => $package,
    notify  => Class['activemq::service'],
  }

  class { 'activemq::config':
    instance                => $instance,
    package                 => $package,
    server_config           => $server_config_real,
    server_config_show_diff => $server_config_show_diff,
    require                 => Class['activemq::packages'],
    notify                  => Class['activemq::service'],
  }

  class { 'activemq::service':
    ensure => $ensure,
  }

  anchor { 'activemq::end':
    require => Class['activemq::service'],
  }

}

