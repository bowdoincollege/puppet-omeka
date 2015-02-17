Omeka Puppet Module
====================

Overview
--------

Puppet Module to install Omeka (http://omeka.org).

The software stack requires and configures:

- `An apache web server`
- `PHP`
-- `with MySQL Bindings`
-- `PEAR`
-- `XML`
- `MySQL Server and automated backups`

Optionally installed are:
- `solr` with a `tomcat` stack
- `other plugins`

The server runs on port 80.

Usage
-----

Example:

    class { 'omeka':
      mysql_root       => 'anexamplerootpassword',
      omekadb_password => 'anomekauserdbpassword'
    }

You can have solr skipped with:

```
solrsearch => false
````

License
-------

Copyright (c) 2015 Paul Nguyen

This script is licensed under the Apache License, Version 2.0.

See http://www.apache.org/licenses/LICENSE-2.0.html for the full license text.


Support
-------

Please log tickets and issues at our [project site](https://github.com/utseresearch/puppet-omeka/issues).
=======
