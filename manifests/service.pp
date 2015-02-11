class wildfly::service(
  $ensure = 'running'
) {

  validate_re($ensure, '^running$|^stopped$')

  #service { 'hivemq':
  #  ensure     => $ensure,
  #  hasstatus  => true,
  #  hasrestart => true
  #}

}
