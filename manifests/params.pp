class donagios::params {

  # Ubuntu uses a single nagios user for nrpe
  case $operatingsystem {
    centos, redhat, fedora: {
      $user_name_nrpe = 'nrpe'
    }
    ubuntu, debian: {
      $user_name_nrpe = 'nagios'
    }
  }
  
}
