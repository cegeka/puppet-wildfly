class wildfly::config(
  $version=undef
){

  validate_re($version, '^[~+._0-9a-zA-Z:-]+$')

  $wildfly_full_version = regsubst($version, '^(\d+\.\d+\.\d+).*','\1')
  $wildfly_major_version = regsubst($version, '^(\d+\.\d+).*','\1')
  $package_version = regsubst($wildfly_major_version, '\.', '', 'G')

  file { "/etc/sysconfig/wildfly${package_version}":
    ensure  => file,
    mode    => '0640',
    content => template("${module_name}/etc/sysconfig/wildfly.erb")
  }

}
