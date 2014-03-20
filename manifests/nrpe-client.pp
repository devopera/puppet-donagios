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
    'command[check_nrpe_procs_smbd]=<%= scope.lookupvar(\'nrpe::pluginsdir\') %>/check_procs -w 1: -c 1: -a smbd',
    'command[check_nrpe_procs_puppetmaster]=<%= scope.lookupvar(\'nrpe::pluginsdir\') %>/check_procs -w 1: -c 1: -a \'puppet master\'',
    'command[check_nrpe_procs_puppetdb]=<%= scope.lookupvar(\'nrpe::pluginsdir\') %>/check_procs -w 1: -c 1: -a puppetdb',
    'command[check_nrpe_procs_postfix]=<%= scope.lookupvar(\'nrpe::pluginsdir\') %>/check_procs -w 1: -c 1: -a postfix',
    # issue WARNING if free space less than 20%
    # issue CRITICAL if free space less than 10%
    'command[check_nrpe_disk]=<%= scope.lookupvar(\'nrpe::pluginsdir\') %>/check_disk -w 20% -c 10% -p /tmp -p /var -p /',
    # issue WARNING if average load over 15-10-5
    # issue CRITICAL if average load over 30-25-20
    # average loads measured over 1, 5, 15 minutes
    'command[check_nrpe_load]=<%= scope.lookupvar(\'nrpe::pluginsdir\') %>/check_load -w 15,10,5 -c 30,25,20',
  ],
  $command_list_extras = [],
  
  # check_nrpe runs commands as nrpe escalated from nagios
  $user_name_nrpe = $donagios::params::user_name_nrpe,
  $user_name_nagios = 'nagios',
  # web server group name
  $group_name = 'www-data',
  
  $notifier_dir = '/etc/puppet/tmp',

  # end of class arguments
  # ----------------------
  # begin class

) inherits donagios::params {

  # set package name
  $packagename = $::operatingsystem ? {
    /(?i:Debian|Ubuntu|Mint)/   => 'nagios-nrpe-server',
    /(?i:SLES|OpenSuSE)/        => $::operatingsystemrelease ? {
      '12.3'   => 'nrpe',
      default  => 'nagios-nrpe',
    },
    /(?i:CentOS|Redhat|Fedora)/ => 'nrpe',
    default                     => 'nrpe',
  }

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
        package => $packagename,
        # secure nrpe by not allowing arguments
        dont_blame_nrpe => 0,
      }
      # open firewall port
      @docommon::fireport { "donagios-nrpe-client-${port}" :
        port => $port,
        protocol => 'tcp',
      }
      # if there's a www-data group
      if defined('dozendserver') {
        # give nrpe access to read files like apache/zend
        exec { 'donagios-nagios-user-group-add' :
          path => '/usr/bin:/usr/sbin',
          command => "gpasswd --add ${user_name_nagios} ${group_name}",
          require => [Class['nrpe'], Class['dozendserver']],
        }
        if ($user_name_nrpe != user_name_nagios) {
          exec { 'donagios-nrpe-user-group-add' :
            path => '/usr/bin:/usr/sbin',
            command => "gpasswd --add ${user_name_nrpe} ${group_name}",
            require => [Class['nrpe'], Class['dozendserver']],
          }
        }
      }
      # tell SELinux to allow NRPE traffic on port
      if (str2bool($::selinux)) {
        if ($ssh_port != 5666) {
          exec { 'nrpe-client-selinux-open-port' :
            path => '/bin:/sbin:/usr/bin:/usr/sbin',
            command => "semanage port -a -t inetd_child_port_t -p tcp ${port} && touch ${notifier_dir}/puppet-nrpe-client-selinux-fix",
            creates => "${notifier_dir}/puppet-nrpe-client-selinux-fix",
            require => [File["${notifier_dir}"]],
          }
        }
      }
    }
  }

}
