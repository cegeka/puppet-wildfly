class wildfly::package(
  $version = undef,
  $versionlock = false
){

  validate_re($version, '^[~+._0-9a-zA-Z:-]+$')
  validate_bool($versionlock)

  package { 'wildfly':
    ensure => $version
  }

  case $versionlock {
    true: {
      packagelock { 'wildfly': }
    }
    false: {
      packagelock { 'wildfly': ensure => absent }
    }
    default: { fail('Class[Wildfly::Package]: parameter versionlock must be true or false') }
  }

}
