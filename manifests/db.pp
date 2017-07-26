# Class: omeka::db
#
# This class installs mysql server and setups the database for omeka.
# Omeka expects db.ini to be populated with database details, we make
# use of a template for that.
#
# Optionally, you can specify a database name and user
#
# == Variables
#
# A root and db password is expected
#
# == Usage
#
# This class is not intended to be used directly. It's automatically
# included by omeka
#

class omeka::db (
  $omeka_db_name       = 'omeka_db',
  $omeka_db_user       = 'omeka',
  $omeka_db_password,
  $mysql_root_password,
) {
  
  class { '::mysql::server':
    root_password    => $mysql_root_password,
    override_options => {
      'mysqld' => {
        'max_connections' => '1024'
      }
    }
  }
  
  class { '::mysql::bindings':
    php_enable => true,
  }
  
  mysql::db { $omekadb_db_name:
    user     => $omeka_db_user,
    password => $omeka_db_password,
    host     => 'localhost',
    grant    => ['ALL'],
    charset  => 'utf8',
    collate  => 'utf8_unicode_ci',
  }
  
#  class { 'mysql::server::backup':
#    backupuser     => 'mysqlbackup',
#    backuppassword => 'Xo4paiM9b',
#    backupdir      => '/var/mysqlbackups',
#  }
}
