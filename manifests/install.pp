# == Class helios::install
#
# Install helios voting server from github
class helios::install (
  $ensure,
  $repo_url,
  $repo_ref,
  $base_dir,
  $helios_web_user,
  $helios_web_group,
  $db_engine,
) {
  include ::helios::params
  validate_absolute_path($base_dir)
  validate_re($ensure, ['^present$','^absent$'])
  validate_re($db_engine, ['^mysql$', '^postgres$'])
  validate_string($repo_url)
  validate_string($repo_ref)
  validate_string($helios_web_user)
  validate_string($helios_web_group)


  user {$helios_web_user:
    ensure     => $ensure,
    comment    => 'Helios web user',
    managehome => true,
    gid        => $helios_web_group,
    shell      => '/bin/bash',
  }

  file {$base_dir:
    ensure => 'directory',
    owner  => $helios_web_user,
    group  => $helios_web_group,
    mode   => '0755',
  }
  vcsrepo {"${base_dir}/helios":
    ensure   => $ensure,
    owner    => $helios_web_user,
    group    => $helios_web_group,
    provider => 'git',
    source   => $repo_url,
    revision => $repo_ref,
    require  => [
      User[$helios_web_user],
      File[$base_dir],
    ]
  }

  class {'::python':
    pip        => true,
    dev        => true,
    virtualenv => true,
  }

  package {$::helios::params::db_engine_packages:
    ensure => 'present',
  }

  ::python::virtualenv {"${base_dir}/virtualenv":
    ensure       => 'present',
    version      => 'system',
    systempkgs   => true,
    requirements => "${base_dir}/helios/requirements.txt",
    owner        => $helios_web_user,
    group        => $helios_web_group,
    cwd          => "${base_dir}/virtualenv",
    timeout      => 0,
    require      => [
      Package[$::helios::params::db_engine_packages],
      Vcsrepo["${base_dir}/helios"]
    ],
  }

  Class['::python'] ->
  Python::Virtualenv["${base_dir}/virtualenv"]
}
