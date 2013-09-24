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

  # flag to stop this run realising nagios services
  $ignore_vnagios = false,

  # refresh config each run
  $purge = true,

  # end of class arguments
  # ----------------------
  # begin class

) {

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

  # test to see if this is a dummy run (creating a new puppetmaster)
  if ($ignore_vnagios) {
    $real_purge = false
    # create a single placeholder host/service (keep nagios happy)
    nagios_host { 'demo-placeholder-host' :
      host_name => 'localhost',
      address => '127.0.0.1',
      use => 'generic-host',
      tag => 'demo-placeholder',
    }
    nagios_service { 'demo-placeholder-service' :
      host_name => 'localhost',
      service_description => 'demo-service',
      check_command => 'check_all_disks',
      use => 'generic-service',
      tag => 'demo-placeholder',
    }
    # tell all the other hosts/services not to be created
    Nagios_host <| tag != 'demo-placeholder' |> {
      noop => true,
    }
    Nagios_service <| tag != 'demo-placeholder' |> {
      noop => true,
    }
  } else {
    $real_purge = $purge
  }

  # disabling for now, because it shouldn't be necessary
  if ($real_purge) {
    # tell all virtual resource realisations to wait for this
    File <| title == 'nagios_confd' |> {
      require => [Exec['nagios-cleardown']]
    }
  
    # clear down previous nagios config if it exists
    exec { 'nagios-cleardown' :
      path => '/usr/bin:/bin',
      # problems regenerating command when refreshed
      # command => 'rm -rf /etc/nagios/conf.d/nagios_{command,host,service}.cfg',
      command => 'rm -rf /etc/nagios/conf.d/nagios_{host,service}.cfg',
      before => Class['nagios::headless'],
    }
  }

  # install nagios but don't ask it to install a webserver
  class { 'nagios::headless' :
  }->
  class { 'nagios::defaults' :
  }->

  # create a host for localhost (server)
  nagios_host { 'donagios-localhost' :
    host_name => $fqdn,
    alias => $hostname,
    address => '127.0.0.1',
    use => 'generic-host',
  }->
  
  # setup services for localhost
  nagios::service { 'donagios-localhost-checkdisks' :
    check_command => 'check_all_disks',
  }->

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

  # open up firewall port if we're not confining it to localhost
  if ( ! $webadmin_limitlocalhost ) {
    class { 'donagios::firewall' :
      webadmin_port => $webadmin_port,
    }
  }

}
