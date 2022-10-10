define wildfly::instance(
  $version = undef,
  $versionlock = false,
  $service_state = 'running',
  $service_enable = true,
  $java_home = '/usr/java/latest',
  $jboss_mode = $wildfly::jboss_mode,
  $jboss_config = $wildfly::jboss_config,
  $jboss_bind_address = $wildfly::jboss_bind_address,
  $jboss_bind_address_mgmt =  $wildfly::jboss_bind_address_mgmt,
  $jboss_min_mem = '256',
  $jboss_max_mem = '512',
  $jboss_perm = '128',
  $jboss_max_perm = '192',
  $jboss_debug = false,
  $jboss_user = 'wildfly',
  $jboss_group = 'wildfly',
  $jboss_data_dir = '/opt/wildfly',
  $jboss_shutdown_wait = '60',
  $jboss_log_dir = $wildfly::jboss_log_dir,
  $users_mgmt = [],
  $newrelic_enabled = false,
  $newrelic_agent_path = '',
  $gc_disabled = false,
) {


  $wildfly_major_version = regsubst($version, '^(\d+)\.\d+.*','\1') # returns e.g. 26
  $package_version = "${wildfly_major_version}0" # returns e.g. 260

  $jboss_data_dir_real = "${jboss_data_dir}${package_version}"
  $jboss_base_dir_real = "${jboss_data_dir_real}/${jboss_mode}"
  $jboss_config_dir_real = "${jboss_data_dir_real}/${jboss_mode}/configuration"
  $jboss_log_dir_real = $jboss_log_dir

  notice("Would enable wildfly instance with version ${version} and java home ${java_home} and data dir: ${jboss_data_dir_real} and mode: ${jboss_mode} and ${jboss_config}")

  package { "wildfly${package_version}":
    ensure => $version,
    name   => "wildfly${package_version}",
  }

  file { "/etc/sysconfig/wildfly${package_version}":
    ensure  => file,
    mode    => '0644',
    content => template("${module_name}/etc/sysconfig/wildfly.erb"),
    notify  => Service['wildfly'],
  }

  file { $jboss_data_dir_real :
    ensure => directory,
    owner  => $jboss_user,
    group  => $jboss_group
  }

  file { $jboss_base_dir_real :
    ensure  => directory,
    owner   => $jboss_user,
    group   => $jboss_group,
    require => File[$jboss_data_dir_real]
  }

  file { "${jboss_base_dir_real}/deployments" :
    ensure  => directory,
    owner   => $jboss_user,
    group   => $jboss_group,
    require => File[$jboss_base_dir_real]
  }

  file { $jboss_config_dir_real :
    ensure  => directory,
    owner   => $jboss_user,
    group   => $jboss_group,
    require => File[$jboss_base_dir_real]
  }

  file { "${jboss_base_dir_real}/configuration/mgmt-users.properties":
    ensure  => file,
    mode    => '0644',
    owner   => $jboss_user,
    group   => $jboss_group,
    content => template("${module_name}/conf/mgmt-users.properties.erb"),
    require => File[$jboss_config_dir_real]
  }

  file { "${jboss_base_dir_real}/configuration/mgmt-groups.properties":
    ensure  => file,
    mode    => '0644',
    owner   => $jboss_user,
    group   => $jboss_group,
    replace => false,
    source  => "puppet:///modules/wildfly/wildfly${package_version}/mgmt-groups.properties",
    require => File[$jboss_config_dir_real]
  }

  file { "${jboss_base_dir_real}/configuration/${jboss_config}.xml":
    ensure  => file,
    mode    => '0664',
    owner   => $jboss_user,
    group   => $jboss_group,
    replace => false,
    source  => "puppet:///modules/wildfly/wildfly${package_version}/${jboss_config}.xml",
    require => File[$jboss_config_dir_real]
  }

  file { "${jboss_base_dir_real}/configuration/logging.properties":
    ensure  => file,
    mode    => '0644',
    owner   => $jboss_user,
    group   => $jboss_group,
    replace => false,
    source  => "puppet:///modules/wildfly/wildfly${package_version}/logging.properties",
    require => File[$jboss_config_dir_real]
  }

  file { "${jboss_base_dir_real}/configuration/application-users.properties":
    ensure  => file,
    mode    => '0644',
    owner   => $jboss_user,
    group   => $jboss_group,
    replace => false,
    source  => "puppet:///modules/wildfly/wildfly${package_version}/application-users.properties",
    require => File[$jboss_config_dir_real]
  }

  file { "${jboss_base_dir_real}/configuration/application-roles.properties":
    ensure  => file,
    mode    => '0644',
    owner   => $jboss_user,
    group   => $jboss_group,
    replace => false,
    source  => "puppet:///modules/wildfly/wildfly${package_version}/application-roles.properties",
    require => File[$jboss_config_dir_real]
  }

if (!defined(Cron["cleanup_old_${jboss_mode}_configuration_files"])){
  cron { "cleanup_old_${jboss_mode}_configuration_files":
    ensure  => present,
    command => "find ${jboss_config_dir_real}/${jboss_mode}_xml_history -type f -mtime +14 -delete",
    hour    => 2,
    minute  => 0
  }
}
if (!defined(Cron["cleanup_empty_${jboss_mode}_configuration_directories"])){
  cron { "cleanup_empty_${jboss_mode}_configuration_directories":
    ensure  => present,
    command => "find ${jboss_config_dir_real}/${jboss_mode}_xml_history -type d -empty -delete",
    hour    => 4,
    minute  => 0
  }
}
}
