class wildfly::service(
  $version = undef,
  $ensure = 'running',
  $enable = true,
  $use_multiple_instances = false,
) {

  validate_re($ensure, '^running$|^stopped$')

  if $use_multiple_instances {
    service { 'wildfly':
      ensure    => $ensure,
      enable    => $enable,
      subscribe => File['/opt/wildfly'],
    }
  } else {

    validate_re($version, '^[~+._0-9a-zA-Z:-]+$')
    $wildfly_major_version = regsubst($version, '^(\d+\.\d+).*','\1')
    $package_version = regsubst($wildfly_major_version, '\.', '', 'G')

    case $ensure {
      'running', 'stopped': {
        service { 'wildfly':
          ensure     => $ensure,
          enable     => $enable,
          hasstatus  => true,
          hasrestart => true
        }
      }
      default: {
        fail('Class[wildfly::service]: parameter ensure must be running, stopped')
      }
    }
  }

}
