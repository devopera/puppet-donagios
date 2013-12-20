class donagios::nrpe-client (

  # class arguments
  # ---------------
  # setup defaults

  # configured to use either duritong or example42
  $provider = 'example42',

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
      # install nrpe
      class { 'nrpe' : }
    }
  }

}
