puppet-donagios
===============

Devopera module for managing hosted nagios config

Changelog
---------

2013-10-11

  * Formalised monitoring and setup virtual resources to monitor nagios itself

2013-09-20

  * Introduced ignore_vnagios to cover scenario when puppeting from a puppetDB-enabled puppetmaster but not one whose virtual resources should get realised, e.g. when puppeting a new puppetmaster.

2013-08-27

  * Moved across to docommon::fireport alias for opening firewall ports

