class donagios (

  # class arguments
  # ---------------
  # setup defaults

  # by default, this target's parent is the puppetmaster
  $parents = $puppetmaster_ipaddress,

  # end of class arguments
  # ----------------------
  # begin class

) {

  class { 'nagios::target' :
    parents => $parents,
  }->

  nagios::service { "int:disks-donagios-${hostname}" :
    check_command => 'check_all_disks',
  }

  # realise virtual (local) resources from other modules
  Nagios::Service <||> { }
}
