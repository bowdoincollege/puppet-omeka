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

  #rpm --import http://li.nux.ro/download/nux/RPM-GPG-KEY-nux.ro
  #rpm -Uvh http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-1.el7.nux.noarch.rpm
  #yum -y install ffmpeg ffmpeg-devel 
  
  #package { 'ffmpeg': ensure => installed }
  
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
    source       => "https://github.com/omeka/Omeka/releases/download/v${omeka_version}/omeka-${omeka_version}.zip",
    extract_path => "${apache_docroot}",
    extract      => true,
    creates      => "${omeka_home}",
    cleanup      => true,
  }

  class { '::omeka::plugins': 
    plugins => {
       'Derivative-Images' => { source => 'https://github.com/omeka/plugin-DerivativeImages/releases/download/v2.0/DerivativeImages-2.0.zip' },
       'HTML5-Media'       => { source => 'https://github.com/zerocrates/Html5Media/releases/download/v2.6/Html5Media-2.6.zip' },
       'Ldap'              => { source => 'https://github.com/BGSU-LITS/LDAP-Plugin/archive/0.3.0.zip' },
    },
    require => Archive["${omeka_zip}"],
  }

  class { '::omeka::themes':
    themes => {
      'clips-omeka-theme' => { source => 'https://github.com/bowdoincollege/clips-omeka-theme/archive/v1.1.zip' }
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
