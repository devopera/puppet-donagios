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

  nagios::service { 'donagios-target-checkdisks' :
    check_command => 'check_all_disks',
  }

}
