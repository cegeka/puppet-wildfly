define wildfly::instance(
  $version = $wildfly::version,
  $versionlock = $wildfly::versionlock,
  $service_state = $wildfly::service_state,
  $service_enable =  $wildfly::service_enable,
  $java_home = $wildfly::java_home,
  $jboss_mode = $wildfly::jboss_mode,
  $jboss_config = $wildfly::jboss_config,
  $jboss_bind_address = $wildfly::jboss_bind_address,
  $jboss_bind_address_mgmt =  $wildfly::jboss_bind_address_mgmt,
  $jboss_min_mem = $wildfly::jboss_min_mem,
  $jboss_max_mem =  $wildfly::jboss_max_mem,
  $jboss_perm =  $wildfly::jboss_perm,
  $jboss_max_perm = $wildfly::jboss_max_perm,
  $jboss_debug = $wildfly::jboss_debug,
  $jboss_user = $wildfly::jboss_user,
  $jboss_group = $wildfly::jboss_group,
  $jboss_data_dir = $wildfly::jboss_data_dir,
  $jboss_shutdown_wait = $wildfly::jboss_shutdown_wait,
  $jboss_log_dir = $wildfly::jboss_log_dir,
  $users_mgmt = $wildfly::users_mgmt,
  $newrelic_enabled = $wildfly::newrelic_enabled,
  $newrelic_agent_path = $wildfly::newrelic_agent_path,
  $gc_disabled = $wildfly::gc_disabled,
  $cpu_quota = $wildfly::cpu_quota,
  String $umask = $wildfly::umask,
) {


  $wildfly_major_version = regsubst($version, '^(\d+)\.\d+.*','\1') # returns e.g. 26
  $package_version = "${wildfly_major_version}0" # returns e.g. 260

  $jboss_data_dir_real = "${jboss_data_dir}${package_version}"
  $jboss_base_dir_real = "${jboss_data_dir_real}/${jboss_mode}"
  $jboss_config_dir_real = "${jboss_data_dir_real}/${jboss_mode}/configuration"
  $jboss_log_dir_real = $jboss_log_dir

  package { "wildfly${package_version}":
    ensure => $version,
    name   => "wildfly${package_version}",
  }

  $bool_versionlock = $versionlock ? {
    true  => 'present',
    false => 'absent',
  }

  case $::operatingsystemmajrelease {
    '8':{
        yum::versionlock { "wildfly${package_version}":
          ensure  => $bool_versionlock,
          version => $version,
          release => '*',
          epoch   => 0,
        }
      }
    default: {
      yum::versionlock { "0:wildfly${package_version}-${version}.*":
        ensure => $bool_versionlock
      }
    }
  }

  file { "/etc/sysconfig/wildfly${package_version}":
    ensure  => file,
    mode    => '0644',
    content => template("${module_name}/etc/sysconfig/wildfly.erb"),
    notify  => $service_state ? {'unmanaged' => undef , default => Service['wildfly']}
  }

  file { "/usr/lib/systemd/system/wildfly${package_version}.service":
    ensure  => file,
    mode    => '0644',
    content => template("${module_name}/usr/lib/systemd/system/wildfly.service.erb"),
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

  if $cpu_quota {
    systemd::service_limits { "wildfly${package_version}.service":
      limits => {
        'CPUQuota' => $cpu_quota,
      },
      notify => Exec['systemctl daemon-reload'],
      before => Class['wildfly::version_select'],
    }
    realize Exec['systemctl daemon-reload']
  }

  if $umask {
    systemd::dropin_file { "${package_version}_umask":
      filename => 'umask.conf',
      path     => '/usr/lib/systemd/system',
      unit     => "wildfly${package_version}.service",
      notify   => Exec['systemctl daemon-reload'],
      content  => "[Service]
UMask=${umask}
",
      require  => Package["wildfly${package_version}"],
      before   => Class['wildfly::version_select'],
    }
  }
}
