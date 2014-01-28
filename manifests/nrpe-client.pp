class donagios::nrpe-client (

  # class arguments
  # ---------------
  # setup defaults

  # configured to use either duritong or example42
  $provider = 'example42',
  $port = 15666,
  $allowed_hosts = ['127.0.0.1'],
  $template = 'donagios/nrpe.cfg.erb',
  
  # by default, lean towards more secure setup
  $dont_blame_nrpe = 0,
  
  # use override to make command list more restricted/secure
  $command_list = [
    'command[check_mount]=<%= scope.lookupvar(\'nrpe::pluginsdir\') %>/check_mount -m "$ARG1$" -t "$ARG2$"',
    'command[check_process]=<%= scope.lookupvar(\'nrpe::pluginsdir\') %>/check_procs -c 1: -C "$ARG1$"',
    'command[check_processwitharg]=<%= scope.lookupvar(\'nrpe::pluginsdir\') %>/check_procs -c 1: -C "$ARG1$" -a "$ARG2$"',
    'command[check_port_tcp]=<%= scope.lookupvar(\'nrpe::pluginsdir\') %>/check_tcp -H "$ARG1$" -p "$ARG2$"',
    'command[check_port_udp]=<%= scope.lookupvar(\'nrpe::pluginsdir\') %>/check_udp -H "$ARG1$" -p "$ARG2$"',
    'command[check_url]=<%= scope.lookupvar(\'nrpe::pluginsdir\') %>/check_http -I "$ARG1$" -p "$ARG2$" -u "$ARG3$" -r "$ARG4$" -A "$ARG5$" -H "$ARG6$"',
    'command[check_url_auth]=<%= scope.lookupvar(\'nrpe::pluginsdir\') %>/check_http -I "$ARG1$" -p "$ARG2$" -u "$ARG3$" -r "$ARG4$" -a "$ARG5$" -A "$ARG6$" -H "$ARG7"',
    'command[check_swap]=<%= scope.lookupvar(\'nrpe::pluginsdir\') %>/check_swap -w 40% -c 20%',
    'command[check_mailq]=<%= scope.lookupvar(\'nrpe::pluginsdir\') %>/check_mailq -w 1 -c 5',
    'command[check_all_disks_param]=<%= scope.lookupvar(\'nrpe::pluginsdir\') %>/check_disk -w <%= scope.lookupvar(\'nrpe::checkdisk_warning\') %> -c <%= scope.lookupvar(\'nrpe::checkdisk_critical\') %> -L -X tmpfs',
    'command[check_users]=<%= scope.lookupvar(\'nrpe::pluginsdir\') %>/check_users -w 5 -c 10',
    'command[check_load]=<%= scope.lookupvar(\'nrpe::pluginsdir\') %>/check_load -w 15,10,5 -c 30,25,20',
    'command[check_zombie_procs]=<%= scope.lookupvar(\'nrpe::pluginsdir\') %>/check_procs -w 5 -c 10 -s Z',
    'command[check_ageandcontent]=<%= scope.lookupvar(\'nrpe::pluginsdir\') %>/check_ageandcontent.pl -f "$ARG1$" -i "$ARG2$" -n "$ARG3$" -m "$ARG4$"',
    'command[check_total_procs]=<%= scope.lookupvar(\'nrpe::pluginsdir\') %>/check_procs -w 150 -c 200', 
    'command[check_ntp]=<%= scope.lookupvar(\'nrpe::pluginsdir\') %>/check_ntp -H <%= scope.lookupvar(\'nrpe::ntp\') %>',
  ],

  # end of class arguments
  # ----------------------
  # begin class

) {

  case $provider {
    'duritong' : {
      # install nrpe
      # doesn't work
      # class { 'nagios::nrpe' : }
    }
    'example42' : {
      # install nrpe using our own template
      class { 'nrpe' :
        port => $port,
        allowed_hosts => $allowed_hosts,
        template => $template,
      }
      # open firewall port
      @docommon::fireport { "donagios-nrpe-client-${port}" :
        port => $port,
        protocol => 'tcp',
      }
    }
  }

}
