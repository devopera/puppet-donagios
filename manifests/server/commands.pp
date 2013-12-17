class donagios::server::commands (

  # class arguments
  # ---------------
  # setup defaults

  # end of class arguments
  # ----------------------
  # begin class

) {

  # setup nagios commands for installed nagios plugins
  nagios_command { 'check_procs' :
    # -H machine IP to check on
    # -w warning RANGE
    # -c critical RANGE
    # -a string to scan command arguments for
    # ranges are min:[max]
    command_line => '$USER1$/check_nrpe -H $HOSTADDRESS$ -c check_procs -a $ARG1$ $ARG2$ $ARG3$'
  }

  # check samba port
  nagios_command { 'check_disk_smb' :
    # -H hostname
    # -s share
    # -W workgroup
    # -a IP address
    # -u username
    # -p password
    command_line => '$USER1$/check_disk_smb -H $ARG1$ -s $ARG2$ -W $ARG3$ -a $ARG4$ -u $ARG5$ -p $ARG6$',
  }
  
  # check https while ignoring cert issues
  nagios_command { 'check_https_nocert' :
    command_line => '$USER1$/check_http --ssl -H $HOSTADDRESS$ -I $HOSTADDRESS$ -C 0',
  }

  # check http with basic authentication
  nagios_command { 'check_http_auth' :
    # -u URL path
    # -p port number
    # -a username:password
    command_line => '$USER1$/check_http -H $HOSTADDRESS$ -I $HOSTADDRESS$ -u $ARG1$ -p $ARG2$ -a $ARG3$',
  }

}
