# See README.md for usage
class omeka() {
  $omeka_version = hiera('omeka::version', "2.5.1")

  $apache_port     = hiera('apache::port', 8080)
  $apache_hostname = hiera('apache::hostname', "localhost")
  $apache_docroot  = hiera('apache::docroot', "/var/www/html")
  $apache_user     = hiera('apache::user', "www-data")

  $omeka_home      = "${apache_docroot}/omeka-${omeka_version}"
  $omeka_zip       = "${apache_docroot}/omeka-${omeka_version}.zip"

  $omeka_db_name       = hiera('omeka::db::name', "omeka_db")
  $omeka_db_user       = hiera('omeka::db::user', "omeka")
  $omeka_db_password   = hiera('omeka::db::password', undefined)
  
  #package { 'imagemagick': ensure => installed }
  package { 'ImageMagick': ensure => installed }
  package { 'curl' : ensure => installed }
  package { 'unzip': ensure => installed }
  
  class { 'selinux':  mode => 'permissive' }
  
  # Apache/PHP Configuration
  class { '::apache': 
    default_vhost => false,
    default_mods  => true,
    mpm_module    => 'prefork',
  }
  
  apache::vhost { $apache_hostname:
    port        => $apache_port,
    docroot     => $omeka_home,
    directories => [
      { 
        path           => $omeka_home,
        allow_override => ['All'],
      }
    ]
  }

  package { 'php':      ensure => 'installed' }
  package { 'php-pear': ensure => installed }
  package { 'php-xml':  ensure => installed }
  class { '::apache::mod::php': 
  }

  archive { "${omeka_zip}":
    ensure       => 'present',
    source       => "http://omeka.org/files/omeka-${omeka_version}.zip",
    extract_path => "${apache_docroot}",
    extract      => true,
    creates      => "${omeka_home}",
    cleanup      => true,
  }

  class { '::omeka::plugins': 
    plugins => {
       'Derivative-Images' => { version => "2.0" },
       'HTML5-Media'       => { version => '2.6' },
       'Ldap'              => { source => 'https://github.com/BGSU-LITS/LDAP-Plugin/archive/0.3.0.zip' },
    },
    require => Archive["${omeka_zip}"],
  }

  class { '::omeka::themes':
    themes => {
      'clips' => { source => 'https://github.com/bowdoincollege/clips-omeka-theme/archive/v1.0.zip' }
    },
   require => Archive["${omeka_zip}"],
  }

  class { '::omeka::db':
    require => Archive["${omeka_zip}"],
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
    owner   => "${apache_user}",
    require => Archive["${omeka_zip}"],
  }

  file { "${omeka_home}/application/logs/errors.log":
    ensure  => file,
    owner   => "${apache_user}",
    mode    => '0644',
    require => Archive["${omeka_zip}"],
  }  

  file { "${omeka_home}/db.ini":
    ensure  => file,
    content => template('omeka/db.ini.erb'),
    owner   => "${apache_user}",
    mode    => '0644',
    require => Archive["${omeka_zip}"],
  }  
}
