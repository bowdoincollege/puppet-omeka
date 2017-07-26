# See README.md for usage
class omeka (
  $omeka_version    = '2.5.1',
  $web_host         = 'localhost',
  $web_port         = 80,
  $web_root         = "/var/www/html",
  $mysql_root_password,
  $omeka_db_user    = 'omeka',
  $omeka_db_password,
  $omeka_db_name    = 'omeka_db',
) {
  $omeka_home       = "{$web_root}/omeka-${omeka_version}"
  $web_user         = "apache"  # Ubuntu = www-data; RHEL = apache
  
  #package { 'imagemagick': ensure => installed }
  package { 'ImageMagick': ensure => installed }
  package { 'curl' : ensure => installed }
  package { 'unzip': ensure => installed }
  
  #class { 'selinux':  mode => 'disabled' }
  
  # Apache/PHP Configuration
  class { '::apache': 
    default_vhost => false,
    default_mods  => true,
    mpm_module    => 'prefork',
  }
  
  apache::vhost { $omeka_hostname:
    port        => '${web_port}',
    docroot     => $omeka_home,
    directories => [
      { 
        path           => $omeka_home,
        allow_override => ['All'],
      }
    ]
  }

  package { 'php': ensure => 'installed' }
  class { '::apache::mod::php': }

  archive { 'omeka-zip':
    ensure    => 'present',
    url       => "http://omeka.org/files/omeka-${omeka_version}.zip",
    target    => '${web_root}',
    extension => 'zip',
    checksum  => false,
  }

  class { '::omeka::plugins': 
  }
  
  class { '::omeka::db':
    mysql_root_password => $mysql_root_password,
    omeka_db_name       => $omeka_db_name,
    omeka_db_user       => $omeka_db_user,
    omeka_db_password   => $omeka_db_password,
    require             => Archive['omeka-zip'],
  }

  file { [
      "${omeka_home}/files",
      "${omeka_home}/files/original",
      "${omeka_home}/files/fullsize",
      "${omeka_home}/files/thumbnails",
      "${omeka_home}/files/square_thumbnails",
      "${omeka_home}/files/theme_uploads",
      "${omeka_home}/application/logs/errors.log",
    ]:
    ensure  => 'directory',
    owner   => '${web_user}',
    require => Archive['omeka-zip'],
  }
  
  file { "${omeka_home}/db.ini":
    ensure  => present,
    content => template('omeka/db.ini.erb'),
    owner   => '${web_user}',
    mode    => '0644',
  }  
}
