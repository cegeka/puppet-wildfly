class wildfly::package(
  $version = undef,
  $versionlock = false
){

  validate_re($version, '^[~+._0-9a-zA-Z:-]+$')
  validate_bool($versionlock)

  $wildfly_full_version = regsubst($version, '^(\d+\.\d+\.\d+).*','\1')
  $wildfly_major_version = regsubst($version, '^(\d+\.\d+).*','\1')
  $package_version = regsubst($wildfly_major_version, '\.', '', 'G')
  $release = regsubst($version, '^(\d+\.\d+\.\d+)-(\d+.\w+.*)','\2')

  $bool_versionlock = $versionlock ? {
    true  => 'present',
    false => 'absent',
  }

  package { "wildfly${package_version}":
    ensure => $version
  }

  case $::operatingsystemmajrelease {
    '8':{
      yum::versionlock { 'wildfly':
        ensure  => $bool_versionlock,
        version => $package_version,
        release => $release,
        epoch   => 0,
      }
    }
    default: {
      yum::versionlock { "0:wildfly${package_version}-${version}.*":
        ensure => $bool_versionlock
      }
    }
  }

  # Only create rc.d init scripts on rhel < 7
  if (versioncmp($::operatingsystemmajrelease, '7') < 0) {
    file { "/etc/init.d/wildfly${package_version}":
      ensure  => file,
      mode    => '0755',
      content => template("${module_name}/etc/init.d/wildfly.erb"),
      require => Package["wildfly${package_version}"]
    }
  }

}
