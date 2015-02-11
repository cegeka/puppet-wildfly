class wildfly::package(
  $version = undef,
  $versionlock = false
){

  validate_re($version, '^[~+._0-9a-zA-Z:-]+$')
  validate_bool($versionlock)

  $wildfly_major_version = regsubst($version, '^(\d+\.\d+).*','\1')
  notice("wildfly_major_version = ${wildfly_major_version}")
  $package_version = regsubst($wildfly_major_version, '\.', '', 'G')

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

}
