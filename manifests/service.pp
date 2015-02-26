class wildfly::service(
  $version = undef,
  $ensure = 'running'
) {

  validate_re($version, '^[~+._0-9a-zA-Z:-]+$')
  validate_re($ensure, '^running$|^stopped$')

  $wildfly_major_version = regsubst($version, '^(\d+\.\d+).*','\1')
  $package_version = regsubst($wildfly_major_version, '\.', '', 'G')

  service { "wildfly${package_version}":
    ensure     => $ensure,
    enable     => true,
    hasstatus  => true,
    hasrestart => true
  }

}
