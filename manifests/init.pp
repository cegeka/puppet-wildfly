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
  $service_state = 'running',
  $service_enable = true,
  $java_home = '/usr/java/latest',
  $jboss_mode = 'standalone',
  $jboss_config = 'standalone',
  $jboss_bind_address = '0.0.0.0',
  $jboss_bind_address_mgmt = '0.0.0.0',
  $jboss_min_mem = '256',
  $jboss_max_mem = '512',
  $jboss_perm = '128',
  $jboss_max_perm = '192',
  $jboss_debug = false,
  $jboss_user = 'wildfly',
  $jboss_group = 'wildfly',
  $jboss_data_dir = '/opt/wildfly',
  $jboss_log_dir = undef,
  $users_mgmt = [],
  $newrelic_enabled = false,
  $newrelic_agent_path = ''
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
    java_home               => $java_home,
    jboss_mode              => $jboss_mode,
    jboss_config            => $jboss_config,
    jboss_bind_address      => $jboss_bind_address,
    jboss_bind_address_mgmt => $jboss_bind_address_mgmt,
    jboss_min_mem           => $jboss_min_mem,
    jboss_max_mem           => $jboss_max_mem,
    jboss_perm              => $jboss_perm,
    jboss_max_perm          => $jboss_max_perm,
    jboss_debug             => $jboss_debug,
    jboss_user              => $jboss_user,
    jboss_group             => $jboss_group,
    jboss_data_dir          => $jboss_data_dir,
    jboss_log_dir           => $jboss_log_dir,
    users_mgmt              => $users_mgmt,
    newrelic_enabled        => $newrelic_enabled,
    newrelic_agent_path     => $newrelic_agent_path
  }

  class { 'wildfly::service':
    ensure  => $service_state,
    version => $version,
    enable  => $service_enable
  }

  Anchor['wildfly::begin'] -> Class['Wildfly::Package'] -> Class['Wildfly::Config'] ~> Class['Wildfly::Service'] -> Anchor['wildfly::end']

}
