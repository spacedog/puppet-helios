# === Class helios
#
# Manages helios voting server
#
# == Parameters
#
# TODO: add parameters
#
# === Authors
#
# Anton Baranov <abaranov@linuxfoundation.org>
#
class helios (
  $ensure           = $::helios::params::ensure,
  $repo_url         = $::helios::params::repo_url,
  $repo_ref         = $::helios::params::repo_ref,
  $base_dir         = $::helios::params::base_dir,
  $helios_web_user  = $::helios::params::helios_web_user,
  $helios_web_group = $::helios::params::helios_web_group,
  $db_engine        = $::helios::params::db_engine,
  $http_socket      = $::helios::params::http_socket,
  $socket           = $::helios::params::socket,
  $app_name         = $::helios::params::app_name,
) inherits helios::params {
  validate_absolute_path($base_dir)
  validate_re($ensure, ['^present$','^absent$'])
  validate_re($db_engine, ['^mysql$', '^postgres$'])
  validate_string($app_name)
  validate_string($helios_web_user)
  validate_string($helios_web_group)
  validate_string($http_socket)
  validate_string($repo_url)
  validate_string($repo_ref)
  validate_string($socket)

  anchor {'helios::begin': }
  anchor {'helios::end': }

  class {'helios::install':
    ensure           => $ensure,
    base_dir         => $base_dir,
    repo_url         => $repo_url,
    repo_ref         => $repo_ref,
    helios_web_user  => $helios_web_user,
    helios_web_group => $helios_web_group,
    db_engine        => $db_engine,
  }

  class {'helios::web':
    ensure      => $ensure,
    app_name    => $app_name,
    base_dir    => $base_dir,
    http_socket => $http_socket,
    socket      => $socket,
    user        => $helios_web_user,
    group       => $helios_web_group,
  }

  Anchor['helios::begin'] ->
    Class['helios::install'] ~>
    Class['helios::web'] ->
  Anchor['helios::end']

}
