class donagios::server (

  # class arguments
  # ---------------
  # setup defaults

  $user = 'web',
  $user_email = 'web@localhost',

  # by default, setup the admin console on non-standard port and limit access to localhost(/tunnels)
  $webadmin_port = 43326,
  $webadmin_limitlocalhost = true,
  $webadmin_user = 'admin',
  $webadmin_password = 'admLn**',

  # refresh config each run
  $purge = true,

  # end of class arguments
  # ----------------------
  # begin class

) {

  # use resource collector to hack nagios::headless->init->CentOS->base
  File <| title == 'nagios_cgi_cfg' |> {
    notify => undef,
  }
 
  if ($purge) {
    # clear down previous nagios config if it exists
    exec { 'nagios-cleardown' :
      path => '/usr/bin:/bin',
      command => 'rm -rf /etc/nagios/conf.d/nagios_*',
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

  # clean up bad permission dir
  exec { 'donagios-permission-cleanup-cmd' :
    path => '/bin:/usr/bin',
    command => 'rm -rf /var/spool/nagios/cmd',
  }->

  # regenerate nagios password
  exec { 'donagios-set-webadmin-password-cmd' :
    path => '/bin:/usr/bin',
    command => "htpasswd -bc /etc/nagios/htpasswd.users '${webadmin_user}' '${webadmin_password}'",
  }->

  # overwrite nagios apache config with template
  file { 'donagios-overwrite-vhost-config' :
    path => '/etc/httpd/conf.d/nagios.conf',
    content => template('donagios/nagios.conf.erb'),
  }->

  # open up access for apache to nagios html files
  exec { 'donagios-open-webadmin-files-cmd' :
    path => '/bin:/usr/bin',
    command => 'chmod -R 755 /usr/share/nagios/html',
    require => [Class['nagios::headless']],
  }->

  # open up access for apache to nagios html files
  exec { 'donagios-access-for-common-user' :
    path => '/bin:/usr/bin',
    command => "chown -R ${user} /etc/nagios",
  }->

  # create symlink in user's home directory
  file { 'donagios-symlink':
    path => "/home/${user}/nagios",
    ensure => 'link',
    target => "/etc/nagios",
  }

  # open up firewall port if we're not confining it to localhost
  if ( ! $webadmin_limitlocalhost ) {
    class { 'donagios::firewall' :
      webadmin_port => $webadmin_port,
    }
  }

}
