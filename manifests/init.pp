class donagios (

  # class arguments
  # ---------------
  # setup defaults

  # by default, this target's parent is the puppetmaster
  $parents = $puppetmaster_ipaddress,

  # by default, realise all local services (send to puppetmaster)
  $realise_local = true,
  
  # by default, monitor machine basics
  $test_load = true,
  $test_disk = true,

  # configured to use either duritong or example42
  $provider = 'duritong',

  # end of class arguments
  # ----------------------
  # begin class

) {

  # this file is included in donagios::server (for local puppetmasters)
  
  # always setup client, but don't rely on unique ${::hostname} for alias
  case $provider {
    'duritong' : {
      class { 'nagios::target' :
        parents => $parents,
        nagios_alias => $::fqdn,
      }
    }
    'example42' : {
      class { 'nagios::target' : }
    }
  }


  if ($realise_local) {
    # realise virtual (local) resources from other modules
    Nagios::Service <||> { }
  }

  if ($test_disk) {
    # monitor disk free space
    @nagios::service { "int:disk_root-donagios-${::fqdn}" :
      # issue WARNING if free space less than 20%
      # issue CRITICAL if free space less than 10%
      check_command => 'check_disk!20%!10%!/',
    }
  }

  if ($test_load) {
    # monitor mean processor load
    @nagios::service { "int:load-donagios-${::fqdn}":
      # issue WARNING if average load over 15-10-5
      # issue CRITICAL if average load over 30-25-20
      # average loads measured over 1, 5, 15 minutes
      check_command => "check_load!15!10!5!30!25!20",
    }
  }

}
