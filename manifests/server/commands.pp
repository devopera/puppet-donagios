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
    # -w warning RANGE
    # -c critical RANGE
    # -C command
    # ranges are min:[max]
    command_line => '$USER1$/check_procs -w $ARG1$ -c $ARG2$ -C $ARG3$'
  }

  # check samba port
  nagios_command { 'check_disk_smb' :
    # -H hostname
    # -s share
    # -W workgroup
    # -a IP address
    # -u username
    # -p password
    command_line => '$USER1$/check_disk_smb -H $ARG1$ -s $ARG2$ -W $ARG3$ -a $ARG4$ -u $ARG5$ -p $ARG6$'
  }
  
  # check https while ignoring cert issues
  nagios_command { 'check_https_nocert' :
    command_line => '$USER1$/check_http --ssl -H $HOSTADDRESS$ -I $HOSTADDRESS$ -C 0'
  }

}
