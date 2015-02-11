
define donagios::server::registercommand(
) {
  # setup a command in nagios to call NRPE to run a remote command on a nrpe-client
  nagios_command { "${title}" :
    command_line => "\$USER1\$/check_nrpe -H \$HOSTADDRESS\$ -p 15666 -t 60 -c ${title}",
  }
}
