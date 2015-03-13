class wildfly::package(
  $version = undef,
  $versionlock = false
){

  validate_re($version, '^[~+._0-9a-zA-Z:-]+$')
  validate_bool($versionlock)

  $wildfly_full_version = regsubst($version, '^(\d+\.\d+\.\d+).*','\1')
  $wildfly_major_version = regsubst($version, '^(\d+\.\d+).*','\1')
  $package_version = regsubst($wildfly_major_version, '\.', '', 'G')
  notice("wildfly_major_version = ${wildfly_major_version}")
  notice("wildfly_full_version = ${wildfly_full_version}")

  package { "wildfly${package_version}":
    ensure => $version
  }

  case $versionlock {
    true: {
      packagelock { "wildfly${package_version}": }
    }
    false: {
      packagelock { "wildfly${package_version}": ensure => absent }
    }
    default: { fail('Class[Wildfly::Package]: parameter versionlock must be true or false') }
  }

  file { "/etc/init.d/wildfly${package_version}":
    ensure  => file,
    mode    => '0755',
    content => template("${module_name}/etc/init.d/wildfly.erb")
  }

  Package["wildfly${package_version}"] -> File["/etc/init.d/wildfly${package_version}"]

}
