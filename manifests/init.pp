class donagios (

  # class arguments
  # ---------------
  # setup defaults

  # by default, this target's parent is the puppetmaster
  $parents = $puppetmaster_ipaddress,

  # but by forcing local (local puppetmaster) we can avoid reinstalling nagios
  $force_local = false,

  # by default, monitor machine basics
  $test_load = true,
  $test_disk = true,

  # end of class arguments
  # ----------------------
  # begin class

) {

  if (!$force_local) {
    class { 'nagios::target' :
      parents => $parents,
    }
  }

  if ($test_disk) {
    # monitor disk free space
    @nagios::service { "int:disk_root-donagios-${hostname}" :
      # issue WARNING if free space less than 20%
      # issue CRITICAL if free space less than 10%
      check_command => 'check_disk!20%!10%!/',
    }
  }

  if ($test_load) {
    # monitor mean processor load
    @nagios::service { "int:load-donagios-${hostname}":
      # issue WARNING if average load over 15-10-5
      # issue CRITICAL if average load over 30-25-20
      # average loads measured over 1, 5, 15 minutes
      check_command => "check_load!15!10!5!30!25!20",
    }
  }

  # realise virtual (local) resources from other modules
  Nagios::Service <||> { }
}
