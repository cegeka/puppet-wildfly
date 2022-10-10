# Class: wildfly::version_select
#
# This module manages the active wildfly version
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class wildfly::version_select(
  $wanted_version = undef,
){

  if !defined('wildfly::instance'){
    fail('wildfly::version_select: at least one instance should be defined')
  }

  if is_numeric($facts['current_wildfly_version']){
    if $wanted_version != $facts['current_wildfly_version'] {
      transition { 'stop wildfly':
        resource   => Service['wildfly'],
        attributes => { ensure => stopped },
        prior_to   => [File['/opt/wildfly'],File['/etc/systemd/system/wildfly.service']],
      }
    }
  }

  file { '/opt/wildfly':
    ensure => link,
    target => "/opt/wildfly${wanted_version}"
  }

  file { '/data/wildfly':
    ensure => link,
    target => "/data/wildfly${wanted_version}"
  }

  file { '/etc/systemd/system/wildfly.service':
    ensure  => link,
    target  => "/usr/lib/systemd/system/wildfly${wanted_version}.service",
    notify  => Exec['systemctl daemon-reload'],
    require => Package["wildfly${wanted_version}"]
  }

  realize Exec['systemctl daemon-reload']
}
