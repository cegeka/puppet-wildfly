class wildfly::service(
  $version = undef,
  $ensure = 'running',
  $enable = true,
  $use_multiple_instances = false,
) {

  validate_re($ensure, '^running$|^stopped$|^unmanaged$')

  if $use_multiple_instances {
    service { 'wildfly':
      ensure    => $ensure,
      enable    => $enable,
      subscribe => File['/opt/wildfly'],
    }
  } else {

    validate_re($version, '^[~+._0-9a-zA-Z:-]+$')
    $package_version = regsubst($wildfly_major_version, '\.', '', 'G')
    $wildfly_major_version = regsubst($version, '^(\d+\.\d+).*','\1')

    case $ensure {
      'running', 'stopped': {
        service { "wildfly${package_version}":
          ensure     => $ensure,
          enable     => $enable,
          hasstatus  => true,
          hasrestart => true
        }
      }
      'unmanaged': {
        notice('Class[wildfly::service]: service is currently not being managed')
      }
      default: {
        fail('Class[wildfly::service]: parameter ensure must be running, stopped or unmanaged')
      }
    }
  }

}
