# == Class: flume
#
# This class is able to install or remove flume on a node.
# It manages the status of the related service.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if it
#   has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should not be used in preference to class parameters  as of
#   Puppet 2.6.)
#
# === Examples
#
#  class { flume:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ]
#  }
#
# === Authors
#
# Stas Alekseev <stas.alekseev@gmail.com>
#
class flume(
  $ensure              = $flume::params::ensure,
  $status              = $flume::params::status,
  $restart_on_change   = $flume::params::restart_on_change,
  $flume_user          = $flume::params::flume_user,
  $flume_group         = $flume::params::flume_group,
  $configdir           = $flume::params::configdir,
  $purge_configdir     = $flume::params::purge_configdir,
) inherits flume::params {

  package { $flume::params::package:
    ensure   => $package_ensure,
    source   => $pkg_source,
    provider => $pkg_provider
  }

  # set params: in operation
  if $ensure == 'present' {
    case $status {
      # make sure service is currently running, start it on boot
      'enabled': {
        $service_ensure = 'running'
        $service_enable = true
      }
      # make sure service is currently stopped, do not start it on boot
      'disabled': {
        $service_ensure = 'stopped'
        $service_enable = false
      }
      # make sure service is currently running, do not start it on boot
      'running': {
        $service_ensure = 'running'
        $service_enable = false
      }
      # do not start service on boot, do not care whether currently running
      # or not
      'unmanaged': {
        $service_ensure = undef
        $service_enable = false
      }
      # unknown status
      # note: don't forget to update the parameter check in init.pp if you
      #       add a new or change an existing status.
      default: {
        fail("\"${status}\" is an unknown service status value")
      }
    }
  }

  service { $flume::params::service_name:
    ensure     => $service_ensure,
    enable     => $service_enable,
    name       => $flume::params::service_name,
    hasstatus  => $flume::params::service_hasstatus,
    hasrestart => $flume::params::service_hasrestart
  }

  File {
    owner => $elasticsearch::elasticsearch_user,
    group => $elasticsearch::elasticsearch_group
  }

  Exec {
    path => [ '/bin', '/usr/bin', '/usr/local/bin' ],
    cwd  => '/',
  }

  if ( $ensure == 'present' ) {

    $notify_service = $restart_on_change ? {
      true  => Service['$flume::params::service_name'],
      false => undef,
    }

    file { $configdir:
      ensure => directory,
      mode   => '0644',
      purge  => $purge_configdir,
      force  => $purge_configdir
    }

    file { "${configdir}/flume.conf":
      ensure  => file,
      content => template("${module_name}/etc/flume-ng/conf/flume.conf.erb"),
      mode    => '0644',
      notify  => $notify_service
    }

  } elsif ( $ensure == 'absent' ) {

    file { $configdir:
      ensure  => 'absent',
      recurse => true,
      force   => true
    }

  }

}

