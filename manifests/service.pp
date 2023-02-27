class wildfly::service(
  $version = undef,
  $ensure = 'running',
  $enable = true,
  $use_multiple_instances = false,
) {

  if $use_multiple_instances {
    case $ensure {
      'running', 'stopped': {
        service { 'wildfly':
          ensure    => $ensure,
          enable    => $enable,
        }
      }
      'unmanaged': {
        notice('Class[wildfly::service]: service is currently not being managed')
      }
      default: {
        fail('Class[wildfly::service]: parameter ensure must be running, stopped or unmanaged')
      }
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
      'unmanaged': {
        notice('Class[wildfly::service]: service is currently not being managed')
      }
      default: {
        fail('Class[wildfly::service]: parameter ensure must be running, stopped')
      }
    }
  }

}
