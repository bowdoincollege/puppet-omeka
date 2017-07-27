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
  $omeka_home       = "${web_root}/omeka-${omeka_version}"
  $omeka_zip        = "${web_root}/omeka-${omeka_version}.zip"
  $web_user         = "apache"  # Ubuntu = www-data; RHEL = apache
  
  #package { 'imagemagick': ensure => installed }
  package { 'ImageMagick': ensure => installed }
  package { 'curl' : ensure => installed }
  package { 'unzip': ensure => installed }
  
  class { 'selinux':  mode => 'disabled' }
  
  # Apache/PHP Configuration
  class { '::apache': 
    default_vhost => false,
    default_mods  => true,
    mpm_module    => 'prefork',
  }
  
  apache::vhost { $web_host:
    port        => $web_port,
    docroot     => $omeka_home,
    directories => [
      { 
        path           => $omeka_home,
        allow_override => ['All'],
      }
    ]
  }

  package { 'php': ensure => 'installed' }
  class { '::apache::mod::php': 
  }

  archive { "${omeka_zip}":
    ensure       => 'present',
    source       => "http://omeka.org/files/omeka-${omeka_version}.zip",
    extract_path => "${web_root}",
    extract      => true,
    creates      => "${omeka_home}",
    cleanup      => false,
  }

  class { '::omeka::plugins': 
  }
  
  class { '::omeka::db':
    mysql_root_password => $mysql_root_password,
    omeka_db_name       => $omeka_db_name,
    omeka_db_user       => $omeka_db_user,
    omeka_db_password   => $omeka_db_password,
    require             => Archive["${omeka_zip}"],
  }

  file { [
      "${omeka_home}/files",
      "${omeka_home}/files/original",
      "${omeka_home}/files/fullsize",
      "${omeka_home}/files/thumbnails",
      "${omeka_home}/files/square_thumbnails",
      "${omeka_home}/files/theme_uploads",
    ]:
    ensure  => 'directory',
    owner   => "${web_user}",
    require => Archive["${omeka_zip}"],
  }

  file { "${omeka_home}/application/logs/errors.log":
    ensure  => file,
    owner   => "${web_user}",
    mode    => '0644',
    require => Archive["${omeka_zip}"],
  }  

  file { "${omeka_home}/db.ini":
    ensure  => file,
    content => template('omeka/db.ini.erb'),
    owner   => "${web_user}",
    mode    => '0644',
    require => Archive["${omeka_zip}"],
  }  
}
