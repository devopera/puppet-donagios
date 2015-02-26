class donagios (

  # class arguments
  # ---------------
  # setup defaults

  # by default, this target's parent is the puppetmaster
  $parents = $puppetmaster_ipaddress,
  $address = $::ipaddress,

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
        # don't include parents because it breaks nagios_host.cfg when realised
        # parents => $parents,
        nagios_alias => $::fqdn,
        address => $address,
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
    # monitor disk free space using nrpe
    # @see donagios::nrpe-client
    @nagios::service { "int:disk_root-donagios-${::fqdn}" :
      check_command => 'check_nrpe_disk',
    }
  }

  if ($test_load) {
    # monitor mean processor load using nrpe
    @nagios::service { "int:load-donagios-${::fqdn}":
      check_command => "check_nrpe_load",
    }
  }

}
