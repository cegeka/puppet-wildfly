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
  $ensure = 'running'
){

  include stdlib

  anchor { 'wildfly::begin': }
  anchor { 'wildfly::end': }

  class { 'wildfly::package':
    version     => $version,
    versionlock => $versionlock
  }

  class { 'wildfly::config':
    version    => $version
  }

  class { 'wildfly::service':
    version => $version,
    ensure  => $ensure
  }

  Anchor['wildfly::begin'] -> Class['Wildfly::Package'] -> Class['Wildfly::Config'] ~> Class['Wildfly::Service'] -> Anchor['wildfly::end']

}
