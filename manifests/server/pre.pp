class donagios::server::pre (

  # class arguments
  # ---------------
  # setup defaults

  # end of class arguments
  # ----------------------
  # begin class

) {

  # clear the nagios config well before the run begins to ensure it's regenerated
  exec { 'nagios-cleardown' :
    path => '/usr/bin:/bin',
    command => 'rm -rf /etc/nagios/conf.d/nagios_{host,service}.cfg',
  }

}
