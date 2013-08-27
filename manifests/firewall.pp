class donagios::firewall (

  # class arguments
  # ---------------
  # setup defaults

  $webadmin_port = 43326,
  
  # end of class arguments
  # ----------------------
  # begin class

) {

  @docommon::fireport { "donagios-webadmin-${webadmin_port}":
    port => $webadmin_port,
    protocol => 'tcp',
  }

}
