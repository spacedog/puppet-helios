# == Class helios::web
#
# Manages uwsgi interface for helios 
#
#
class helios::web(
  $ensure,
  $app_name,
  $base_dir,
  $http_socket,
  $socket,
  $user,
  $group,
) {
  validate_absolute_path($base_dir)
  validate_re($ensure, ['^present$', '^absent$'])
  validate_string($app_name)
  validate_string($group)
  validate_string($http_socket)
  validate_string($socket)
  validate_string($user)
  
  class {'::uwsgi':
    install_pip         => false,
    install_python_dev  => false,
    service_provider    => 'redhat',
    package_provider    => 'yum',
    package_name        => [
        'uwsgi',
        'uwsgi-plugin-python',
      ],
    manage_service_file => false,
    }
    
    $application_options = {
      'socket'       => $socket,
      'http-socket'  => $http_socket,
      'chdir'        => "${base_dir}/helios",
      'virtualenv'   => "${base_dir}/virtualenv",
      'pythonpath'   => "${base_dir}/helios",
      'daemonize'    => "${base_dir}/uwsgi.log",
      'static-map'   => "/static=${base_dir}/static",
      'module'       => 'wsgi',
      'env'          => 'DJANGO_SETTINGS_MODULE=settings',
      'plugins'      => 'python',
      'processes'    => 4,
      'threads'      => 8,
      'harakiri'     => 16,
      'max-requests' => 5000,
      'vacuum'       => true,
    }
    
    uwsgi::app { $app_name:
      ensure              => $ensure,
      uid                 => $user,
      gid                 => $group,
      application_options => $application_options,
    }
}
