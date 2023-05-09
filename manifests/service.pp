class wildfly::service(
  $version = undef,
  $ensure = 'running',
  $enable = true,
) {

  case $ensure {
    'running', 'stopped': {
      service { 'wildfly':
        ensure  => $ensure,
        enable  => $enable,
        require => Exec['systemctl daemon-reload'],
      }
    }
    'unmanaged': {
      notice('Class[wildfly::service]: service is currently not being managed')

      # this still allows notifying the service for a restart
      service { 'wildfly':
        require => Exec['systemctl daemon-reload']
      }
    }
    default: {
      fail('Class[wildfly::service]: parameter ensure must be running, stopped or unmanaged')
    }
  }
}
