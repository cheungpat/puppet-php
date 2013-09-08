# Class: php::fpm::daemon
#
# Install the PHP FPM daemon. See php::fpm::conf for configuring its pools.
#
# Sample Usage:
#  include php::fpm::daemon
#
class php::fpm::daemon (
  $ensure                       = 'present',
  $log_level                    = 'notice',
  $emergency_restart_threshold  = '0',
  $emergency_restart_interval   = '0',
  $process_control_timeout      = '0',
  $log_owner                    = 'root',
  $log_group                    = false,
  $log_dir_mode                 = '0770'
) {

  # Hack-ish to default to user for group too
  $log_group_final = $log_group ? {
    false   => $log_owner,
    default => $log_group,
  }

  if ( $ensure == 'absent' ) {

    package { $php::fpm::params::package:
      ensure => absent
    }

  } else {

    package { $php::fpm::params::package:
      ensure => installed
    }

    service { $php::fpm::params::service:
      ensure    => running,
      enable    => true,
      hasstatus => true,
      require   => Package[$php::fpm::params::package],
    }

    file { $php::fpm::params::conffile:
      notify  => Service[$php::fpm::params::service],
      content => template('php/fpm/php-fpm.conf.erb'),
      owner   => root,
      group   => root,
      mode    => '0644',
    }

  }

}
