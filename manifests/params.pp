# Class helios::params
#
# Sets default values for helios class
class helios::params {
  $ensure             = 'present'
  $repo_url           = 'https://github.com/benadida/helios-server.git'
  $repo_ref           = 'f5dc954c12eacbeb221646511e47537307a941aa'
  $base_dir           = '/opt/helios-web'
  $helios_web_user    = 'helios'
  $helios_web_group   = 'helios'
  $db_engine          = 'mysql'
  $db_engine_packages = ['MySQL-python', 'postgresql-devel']

  case $db_engine {
    'mysql': {
      $db_engine_backend  = 'mysql'
    }
    'postgres': {
      $db_engine_backend  = 'postgresql_psycopg2'
    }
  }

}

