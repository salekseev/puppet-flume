# == Class: flume::params
#
# This class exists to
# 1. Declutter the default value assignment for class parameters.
# 2. Manage internally used module variables in a central place.
#
# Therefore, many operating system dependent differences (names, paths, ...)
# are addressed in here.
#
#
# === Parameters
#
# This class does not provide any parameters.
#
#
# === Examples
#
# This class is not intended to be used directly.
#
#
# === Links
#
# * {Puppet Docs: Using Parameterized Classes}[http://j.mp/nVpyWY]
#
#
# === Authors
#
# * Stas Alekseev <mailto:stas.alekseev@gmail.com>
#
class flume::params {

  #### Default values for the parameters of the main module class, init.pp

  # ensure
  $ensure = 'present'

  # service status
  $status = 'enabled'

  # restart on configuration change?
  $restart_on_change = true

  # Purge configuration directory
  $purge_configdir = false

  #### Internal module values

  # User and Group for the files and user to run the service as.
  case $::kernel {
    'Linux': {
      $flume_user  = 'flume'
      $flume_group = 'flume'
    }
    default: {
      fail("\"${module_name}\" provides no user/group default value
           for \"${::kernel}\"")
    }
  }

  # Different path definitions
  case $::kernel {
    'Linux': {
      $configdir   = '/etc/flume-ng/conf'
    }
    default: {
      fail("\"${module_name}\" provides no config directory default value
           for \"${::kernel}\"")
    }
  }

  # packages
  case $::operatingsystem {
    'RedHat', 'CentOS', 'Fedora', 'Scientific', 'Amazon', 'OracleLinux': {
      # main application
      $package = [ 'flume-ng-agent' ]
    }
    default: {
      fail("\"${module_name}\" provides no package default value
            for \"${::operatingsystem}\"")
    }
  }

  # service parameters
  case $::operatingsystem {
    'RedHat', 'CentOS', 'Fedora', 'Scientific', 'Amazon', 'OracleLinux': {
      $service_name       = 'flume-ng-agent'
      $service_hasrestart = true
      $service_hasstatus  = true
    }
    default: {
      fail("\"${module_name}\" provides no service parameters
            for \"${::operatingsystem}\"")
    }
  }

}
