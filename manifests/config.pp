class wildfly::config(
  $version = undef,
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
  $jboss_data_dir = '/opt/wildfly',
  $users_mgmt = [],
  $newrelic_enabled = false,
  $newrelic_agent_path = ''
){

  validate_re($version, '^[~+._0-9a-zA-Z:-]+$')
  validate_re($jboss_mode, '^standalone$|^domain$')
  validate_re($jboss_config, '^standalone$|^standalone-full$|^standalone-ha$|^standalone-full-ha$')
  validate_bool($jboss_debug)
  validate_bool($newrelic_enabled)

  $wildfly_full_version = regsubst($version, '^(\d+\.\d+\.\d+).*','\1')
  $wildfly_major_version = regsubst($version, '^(\d+\.\d+).*','\1')
  $package_version = regsubst($wildfly_major_version, '\.', '', 'G')

  $jboss_data_dir_real = "${jboss_data_dir}${package_version}"
  $jboss_base_dir_real = "${jboss_data_dir_real}/${jboss_mode}"
  $jboss_config_dir_real = "${jboss_data_dir_real}/${jboss_mode}/configuration"
  $jboss_log_dir_real = "${jboss_data_dir_real}/${jboss_mode}/log"

  file { "/etc/sysconfig/wildfly${package_version}":
    ensure  => file,
    mode    => '0640',
    content => template("${module_name}/etc/sysconfig/wildfly.erb")
  }

  file { '/etc/wildfly.conf':
    ensure  => file,
    mode    => '0644',
    content => template("${module_name}/etc/wildfly.conf.erb")
  }

  file { $jboss_data_dir_real :
    ensure => directory,
    owner  => $jboss_user,
    group  => 'wildfly'
  }

  file { $jboss_base_dir_real :
    ensure  => directory,
    owner   => $jboss_user,
    group   => 'wildfly',
    require => File[$jboss_data_dir_real]
  }

  file { $jboss_config_dir_real :
    ensure  => directory,
    owner   => $jboss_user,
    group   => 'wildfly',
    require => File[$jboss_base_dir_real]
  }

  file { "${jboss_base_dir_real}/configuration/mgmt-users.properties":
    ensure  => file,
    mode    => '0644',
    owner   => $jboss_user,
    group   => 'wildfly',
    content => template("${module_name}/conf/mgmt-users.properties.erb"),
    require => File[$jboss_config_dir_real]
  }

  file { "${jboss_base_dir_real}/configuration/mgmt-groups.properties":
    ensure  => file,
    mode    => '0644',
    owner   => $jboss_user,
    group   => 'wildfly',
    replace => false,
    source  => "puppet:///modules/wildfly/mgmt-groups.properties",
    require => File[$jboss_config_dir_real]
  }

  file { "${jboss_base_dir_real}/configuration/${jboss_config}.xml":
    ensure  => file,
    mode    => '0644',
    owner   => $jboss_user,
    group   => 'wildfly',
    replace => false,
    source  => "puppet:///modules/wildfly/${jboss_config}.xml",
    require => File[$jboss_config_dir_real]
  }

  file { "${jboss_base_dir_real}/configuration/logging.properties":
    ensure  => file,
    mode    => '0644',
    owner   => $jboss_user,
    group   => 'wildfly',
    replace => false,
    source  => "puppet:///modules/wildfly/logging.properties",
    require => File[$jboss_config_dir_real]
  }

  file { "${jboss_base_dir_real}/configuration/application-users.properties":
    ensure  => file,
    mode    => '0644',
    owner   => $jboss_user,
    group   => 'wildfly',
    replace => false,
    source  => "puppet:///modules/wildfly/application-users.properties",
    require => File[$jboss_config_dir_real]
  }

  file { "${jboss_base_dir_real}/configuration/application-roles.properties":
    ensure  => file,
    mode    => '0644',
    owner   => $jboss_user,
    group   => 'wildfly',
    replace => false,
    source  => "puppet:///modules/wildfly/application-roles.properties",
    require => File[$jboss_config_dir_real]
  }

  cron { "cleanup_old_${jboss_mode}_configuration_files":
    ensure  => present,
    command => "find ${jboss_config_dir_real}/${jboss_mode}_xml_history -type f -mtime +14 -exec rm -rf {} \;",
    hour    => 2,
    minute  => 0
  }

  cron { "cleanup_empty_${jboss_mode}_configuration_directories":
    ensure  => present,
    command => "find ${jboss_config_dir_real}/${jboss_mode}_xml_history -type d -empty -exec rm -rf {} \;",
    hour    => 4,
    minute  => 0
  }

}
