class donagios::nrpe-client (

  # class arguments
  # ---------------
  # setup defaults

  # configured to use either duritong or example42
  $nagios_provider = 'duritong',

  # end of class arguments
  # ----------------------
  # begin class

) {

  case $nagios_provider {
    'duritong' : {
      # install nrpe
      # doesn't work
      # class { 'nagios::nrpe' : }
    }
    'example42' : {
      # install nrpe
      class { 'nrpe' : }
    }
  }

}
