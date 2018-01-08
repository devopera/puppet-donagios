class donagios::server::commands (

  # class arguments
  # ---------------
  # setup defaults

  # end of class arguments
  # ----------------------
  # begin class

) {

  # setup nagios commands for installed nagios plugins

  # REMOTE
  # see nrpe-client.pp for client-side setup of NRPE-accessible commands
  
  # use nrpe to check X process is running
  nagios_command { 'check_nrpe_procs_smbd' :
    command_line => '$USER1$/check_nrpe -H $HOSTADDRESS$ -p 15666 -t 60 -c check_nrpe_procs_smbd'
  }
  nagios_command { 'check_nrpe_procs_postfix' :
    command_line => '$USER1$/check_nrpe -H $HOSTADDRESS$ -p 15666 -t 60 -c check_nrpe_procs_postfix'
  }
  nagios_command { 'check_nrpe_procs_puppetmaster' :
    command_line => '$USER1$/check_nrpe -H $HOSTADDRESS$ -p 15666 -t 60 -c check_nrpe_procs_puppetmaster'
  }
  nagios_command { 'check_nrpe_procs_puppetserver' :
    command_line => '$USER1$/check_nrpe -H $HOSTADDRESS$ -p 15666 -t 60 -c check_nrpe_procs_puppetserver'
  }
  nagios_command { 'check_nrpe_procs_puppetdb' :
    command_line => '$USER1$/check_nrpe -H $HOSTADDRESS$ -p 15666 -t 60 -c check_nrpe_procs_puppetdb'
  }
  nagios_command { 'check_nrpe_procs_node' :
    command_line => '$USER1$/check_nrpe -H $HOSTADDRESS$ -p 15666 -t 60 -c check_nrpe_procs_node'
  }
  
  # use nrpe to check disk has enough free space
  nagios_command { 'check_nrpe_disk' :
    command_line => '$USER1$/check_nrpe -H $HOSTADDRESS$ -p 15666 -t 60 -c check_nrpe_disk'
  }

  # use nrpe to check process load
  nagios_command { 'check_nrpe_load' :
    command_line => '$USER1$/check_nrpe -H $HOSTADDRESS$ -p 15666 -t 60 -c check_nrpe_load'
  }

  # LOCAL
  # executed on the nagios server (typically the puppetmaster)

  # check local service
  nagios_command { 'check_local_procs' :
    # -w warning level
    # -c critical level
    # -a command arguments (for process matching)
    command_line => '$USER1$/check_procs -w $ARG1$ -c $ARG2$ -a $ARG3$',
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

  # check file age
  nagios_command { 'check_file_age' :
    # -f filename
    # -w age in seconds (warning)
    # -c age in seconds (critical)
    # -W min size in bytes (warning)
    # -C min size in bytes (critical)
    command_line => '$USER1$/check_file_age -w $ARG2$ -c $ARG3$ -W $ARG4$ -C $ARG5$ -f $ARG1$',
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

    # create command for handling detailed https checks
  nagios_command { 'check_https_port_url_content_auth' :
    # -H hostname
    # -p port
    # -u path
    # -s string to match
    # -a auth username:password
    # --expect response code (e.g. 200)
    command_line => '$USER1$/check_http --ssl -H $ARG1$ -p $ARG2$ -u $ARG3$ -s $ARG4$ -a $ARG5$ --expect $ARG6$',
  }

  # check https content using regex
  nagios_command { 'check_https_port_url_regex' :
    # -r regex (case sensitive)
    command_line => '$USER1$/check_http --ssl -H $ARG1$ -p $ARG2$ -u $ARG3$ -r $ARG4$',
  }

}
