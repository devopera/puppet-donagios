class donagios::server (

  # class arguments
  # ---------------
  # setup defaults

  $user = 'web',
  $user_email = 'web@localhost',
  $group = 'nagios',
  $group_web = 'www-data',

  # by default, setup the admin console on non-standard port and limit access to localhost(/tunnels)
  $webadmin_port = 43326,
  $webadmin_limitlocalhost = true,
  $webadmin_user = 'admin',
  $webadmin_password = 'admLn**',

  # flag to make this run realise nagios exported resources
  $force_local = false,

  # refresh config each run
  $purge = true,

  # firewall and monitor
  $firewall = true,
  $monitor = true,

  # configured to use either duritong or example42
  $provider = 'duritong',

  # end of class arguments
  # ----------------------
  # begin class

) {

  # open up firewall port if we're not confining it to localhost and monitor
  if (!$webadmin_limitlocalhost) {
    if ($firewall) {
      class { 'donagios::firewall' :
        webadmin_port => $webadmin_port,
      }
    }
    if ($monitor) {
      class { 'donagios::monitor' :
        webadmin_port => $webadmin_port,
        webadmin_user => $webadmin_user,
        webadmin_password => $webadmin_password,
      }
    }
  }

  # if we've got a message of the day, include
  @domotd::register { "Nagios(${webadmin_port})" : }

  # work out if we're staging out a new puppetmaster, or puppetting ourselves from a local one
  # Note
  # 1. can't use master_use_original because we might be doing a 1st run, where the 2nd run won't use_original
  # 2. can't see if the puppetmaster_ipaddress from the hosts file is us, because it's never us
  # 3. can test the current (not future or end-run state) puppet.conf file for a directive pointing to another puppetmaster

  # if the puppetmaster server is explicitly set to point at our hostname/fqdn/ip
  if (($puppetmaster_directive_name == $::hostname) or ($puppetmaster_directive_name == $::fqdn) or ($puppetmaster_directive_name == $::ipaddress)) {
    $detect_local = true
  } else {
    $detect_local = false
  }

  # could setup our own config file
  File <| title == 'nagios_main_cfg' |> {
  }

  # we are a puppetmaster so there's no nagios::target include/profile, so we want to realise virtual (local) resources (for export), but not realise exported resources locally (for local new puppetmaster)
  class { 'donagios' :
    realise_local => true,
  }

  # pull in commands for nagios plugins
  class { 'donagios::server::commands' : }

  case $provider {
    'duritong' : {
      # use resource collector to hack nagios::headless->init->CentOS->base
      # don't notify apache
      File <| title == 'nagios_cgi_cfg' |> {
        notify => undef,
      }
      # all nagios resources should be web:nagios
      # no wildcards/regex in resource collectors, so duplication
      File <| title == 'nagios_main_cfg' or title == 'nagios_cgi_cfg' or title == 'nagios_htpasswd' or title == 'nagios_private' or title == 'nagios_private_resource_cfg' or title == 'nagios_confd' |> {
        owner => $user,
        group => $group,
      }
    }
    'example42' : {
    }
  }
     

  # test to see if this is a 1st run (creating a new puppetmaster)
  if ((!$detect_local) and (!$force_local)) {
    # in this case we're creating a new puppetmaster, so we want to avoid
    # pulling it its puppetDB stored_configs (exported resources)
    notify { "Creating a new puppetmaster (${::hostname}), probably spawned from ${::puppetmaster_ipaddress}": }
  
    # never purge, because we're doing this from scratch
    $real_purge = false

    # create a single placeholder host/service locally (to keep nagios happy)
    nagios_host { 'demo-placeholder-host' :
      host_name => 'localhost',
      address => '127.0.0.1',
      use => 'generic-host',
    }
    nagios_service { 'demo-placeholder-service' :
      host_name => 'localhost',
      service_description => 'demo-service',
      check_command => 'check_all_disks',
      use => 'generic-service',
    }

    # now realise all virtual resources, but do not collect exported (because they weren't exported to us)
    # tell all the other hosts/services not to be created
    Nagios_host <| |> {
      noop => true,
    }
    Nagios_service <| |> {
      noop => true,
    }
    Nagios_host <| title == $::fqdn |> {
      noop => false,
    }
    Nagios_service <| host_name == $::fqdn |> {
      noop => false,
    }
    
  } else {
     # in this case we're puppeting from ourselves (local puppetmaster)
    notify { "Self-puppetting from local puppetmaster (${::hostname}), puppet.conf server = ${::puppetmaster_directive_name}": }

    # remove localhost entry because we should have exported/be exporting a resource for this machine
    nagios_host { 'demo-placeholder-host' :
      host_name => 'localhost',
      ensure => 'absent'
    }

    # only purge if we're set to purge
    $real_purge = $purge
  }

  case $provider {
    'duritong' : {
      # install nagios but don't ask it to install a webserver
      class { 'nagios::headless' :
      }->
      class { 'nagios::defaults' :
        before => Exec['donagios-permission-cleanup-cmd'],
      }
    }
    'example42' : {
      class { 'nagios' :
        install_prerequisites => false,
        before => Exec['donagios-permission-cleanup-cmd'],
      }
    }
  }

  # clean up dir with wrong permissions
  exec { 'donagios-permission-cleanup-cmd' :
    path => '/bin:/usr/bin',
    command => 'rm -rf /var/spool/nagios/cmd',
  }->

  # overwrite nagios apache config with template
  file { 'donagios-overwrite-vhost-config' :
    path => '/etc/httpd/conf.d/nagios.conf',
    content => template('donagios/nagios.conf.erb'),
    owner => $user,
    group => $group,
  }->

  # open up access for apache to nagios html files
  exec { 'donagios-open-webadmin-files-cmd' :
    path => '/bin:/usr/bin',
    command => "chown -R ${user}:www-data /usr/share/nagios/html && chmod -R 640 /usr/share/nagios/html && find /usr/share/nagios/html -type d -exec chmod 750 {} \;",
  }->

  # open up access for web to nagios config directory
  exec { 'donagios-access-for-common-user' :
    path => '/bin:/usr/bin',
    command => "chown -R ${user}:nagios /etc/nagios && chmod -R 660 /etc/nagios && find /etc/nagios -type d -exec chmod 770 {} \;",
  }->

  # create symlink in user's home directory
  file { 'donagios-config-symlink':
    path => "/home/${user}/nagios-config",
    ensure => 'link',
    target => "/etc/nagios",
  }->
  file { 'donagios-web-interface-symlink':
    path => "/home/${user}/nagios-html",
    ensure => 'link',
    target => "/usr/share/nagios/html/",
  }->

  # regenerate nagios password file from scratch
  exec { 'donagios-set-webadmin-password-cmd' :
    path => '/bin:/usr/bin',
    command => "htpasswd -bc /etc/nagios/htpasswd.users '${webadmin_user}' '${webadmin_password}'",
    user => $user,
    group => $group,
  }
  # and tell Nagios not to use its templated htpasswd
  File <| title == 'nagios_htpasswd' |> {
    noop => true,
  }

  if (str2bool($::selinux)) {
    # tweak the context of check_disk_smb to allow nagios to access it
    docommon::setcontext { 'donagios-server-selinux-tweak-checksmb' :
      filename => $::hardwaremodel ? {
        'x86_64' => '/usr/lib64/nagios/plugins/check_disk_smb',
        default => '/usr/lib/nagios/plugins/check_disk_smb',
      },
      # from nagios_checkdisk_plugin_exec_t -> nagios_services_plugin_exec_t
      context => 'nagios_services_plugin_exec_t',
      notify => [Service['nagios']],
    }
  }  

}
