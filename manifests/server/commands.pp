class donagios::server::commands (

  # class arguments
  # ---------------
  # setup defaults

  # end of class arguments
  # ----------------------
  # begin class

) {

  # setup nagios commands for default (installed) nagios plugins
  nagios_command { 'check_procs' :
    # ranges are min:[max]
    command_line => '$USER1$/check_procs -w $ARG1$ -c $ARG2$ -C $ARG3$'
  }

}
