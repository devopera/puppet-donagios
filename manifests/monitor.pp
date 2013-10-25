class donagios::monitor (

  # class arguments
  # ---------------
  # setup defaults

  $webadmin_port = 43326,
  $webadmin_user = 'admin',
  $webadmin_password = 'admLn**',
  
  # end of class arguments
  # ----------------------
  # begin class

) {

  if ($webadmin_port) {
    @nagios::service { "http:${webadmin_port}-donagios-${::hostname}":
      check_command => "check_http_auth!/!${webadmin_port}!${webadmin_user}:${webadmin_password}",
    }
    @nagios::service { "int:process_nagios-donagios-${::hostname}":
      check_command => "check_procs!1:!1:!nagios",
    }
  }

}
