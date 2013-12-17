class donagios::nrpe (

  # class arguments
  # ---------------
  # setup defaults

  # end of class arguments
  # ----------------------
  # begin class

) {

  # install nrpe
  class { 'nagios::nrpe' : }

  # setup commands
  nagios::nrpe::command { 'check_procs':
    command_line => 'check_procs -w $ARG1$ -c $ARG2$ -a $ARG3$',
  }

}
