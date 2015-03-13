class wildfly::config(
  $version=undef
  $version = undef,
  $jboss_mode = 'standalone',
  $jboss_config = 'standalone',
  $jboss_bind_address = '0.0.0.0',
  $jboss_bind_address_mgmt = '0.0.0.0',
){

  validate_re($version, '^[~+._0-9a-zA-Z:-]+$')
  validate_re($jboss_mode, '^standalone$|^domain$')
  validate_re($jboss_config, '^standalone$|^standalone-full$|^standalone-ha$|^standalone-full-ha$')

  $wildfly_full_version = regsubst($version, '^(\d+\.\d+\.\d+).*','\1')
  $wildfly_major_version = regsubst($version, '^(\d+\.\d+).*','\1')
  $package_version = regsubst($wildfly_major_version, '\.', '', 'G')

  file { "/etc/sysconfig/wildfly${package_version}":
    ensure  => file,
    mode    => '0640',
    content => template("${module_name}/etc/sysconfig/wildfly.erb")
  }

  file { "/etc/wildfly.conf":
    ensure  => file,
    mode    => '0640',
    content => template("${module_name}/etc/wildfly.conf.erb")
  }
  cron { "cleanup_old_${jboss_mode}_configuration_files":
    ensure  => present,
    command => "find /opt/wildfly${package_version}/${jboss_mode}/configuration/${jboss_mode}_xml_history -type f -mtime +14 -exec rm -rf {} \;",
    hour    => 2,
    minute  => 0
  }

  cron { "cleanup_empty_${jboss_mode}_configuration_directories":
    ensure  => present,
    command => "find /opt/wildfly${package_version}/${jboss_mode}/configuration/${jboss_mode}_xml_history -type d -empty -exec rm -rf {} \;",
    hour    => 4,
    minute  => 0
  }
}
