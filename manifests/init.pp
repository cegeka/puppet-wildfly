# Class: wildfly
#
# This module manages wildfly
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class wildfly(
  $version = undef,
  $versionlock = false,
  $ensure = 'running',
  $jboss_mode = 'standalone',
  $jboss_config = 'standalone',
  $jboss_bind_address = '0.0.0.0',
  $jboss_bind_address_mgmt = '0.0.0.0',
  $users_mgmt = []
){

  include stdlib

  anchor { 'wildfly::begin': }
  anchor { 'wildfly::end': }

  class { 'wildfly::package':
    version     => $version,
    versionlock => $versionlock
  }

  class { 'wildfly::config':
    version                 => $version,
    jboss_mode              => $jboss_mode,
    jboss_config            => $jboss_config,
    jboss_bind_address      => $jboss_bind_address,
    jboss_bind_address_mgmt => $jboss_bind_address_mgmt,
    users_mgmt              => $users_mgmt
  }

  class { 'wildfly::service':
    version => $version,
    ensure  => $ensure
  }

  Anchor['wildfly::begin'] -> Class['Wildfly::Package'] -> Class['Wildfly::Config'] ~> Class['Wildfly::Service'] -> Anchor['wildfly::end']

}
