[devopera](http://devopera.com)-[donagios](http://devopera.com/module/donagios)
===============

Devopera module for managing hosted nagios config.  You can [download a virtual machine](http://devopera.com/applications/nagios-and-puppetmaster-puppetdb) that demonstrates the use of this module.

Changelog
---------

2014-11-25

  * Made nagios sensitive to but not dependent upon doapache, but it does need a web server for admin UI

2014-03-06

  * Added nrpe/nagios users to www-data group to allow monitoring of file timestamps, e.g. database backups

2014-02-04

  * NRPE-based client service, load and disk checking, without command arguments for security

2013-10-11

  * Formalised monitoring and setup virtual resources to monitor nagios itself

2013-09-20

  * Introduced ignore_vnagios to cover scenario when puppeting from a puppetDB-enabled puppetmaster but not one whose virtual resources should get realised, e.g. when puppeting a new puppetmaster.

2013-08-27

  * Moved across to docommon::fireport alias for opening firewall ports

Usage
-----

This module also requires either [Example42's nagios](https://github.com/example42/puppet-nagios) or [Duritong's nagios](https://github.com/duritong/puppet-nagios) module, though the latter isn't available on Puppet Forge.

Create a target (a machine that should be monitored)

    class { 'donagios' : }

Create a server (must not also be a target)

    class { 'donagios::server' : }

Force nagios to refresh config on server each time

    class { 'donagios::server::pre' : }->
    class { 'donagios::server' : }

Operating System support
------------------------

Tested with CentOS 6

Copyright and License
---------------------

Copyright (C) 2012 Lightenna Ltd

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
