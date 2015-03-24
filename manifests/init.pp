# See README.md for usage
class omeka (
  $omeka_ver        = '2.2.2',
  $omeka_hostname,
  $mysql_root,
  $omekadb_user     = 'omeka',
  $omekadb_password,
  $omekadb_dbname   = 'omeka_db',
  $solrsearch       = true,
  $solr_ver         = '4.10.2'
) {

  $solr_binary      = "http://mirror.aarnet.edu.au/pub/apache/lucene/solr/${solr_ver}/solr-${solr_ver}.tgz"
  #$solr_binary      = "http://apache.mirror.digitalpacific.com.au/lucene/solr/${solr_ver}/solr-${solr_ver}.tgz"
  #$solr_binary      = "http://www.apache.org/dist/lucene/solr/${solr_ver}/solr-${solr_ver}.tgz"
  $omeka_home       = "/var/www/html/omeka-${omeka_ver}"
  $omeka_solrconf   = "${omeka_home}/plugins/SolrSearch/solr-core/omeka/conf/solrconfig.xml"
  
  class { '::omeka::db':
    omeka_home       => $omeka_home,
    mysql_root       => $mysql_root,
    omekadb_dbname   => $omekadb_dbname,
    omekadb_user     => $omekadb_user,
    omekadb_password => $omekadb_password,
    require          => Archive['omeka-zip'],
  }
  
  class { '::apache': }
  
  apache::vhost { $omeka_hostname:
    port        => '80',
    docroot     => $omeka_home,
    directories => [
      { path           => $omeka_home,
        allow_override => ['All'],
      }
    ]
  }
  
  package { 'ImageMagick':  ensure => installed, }
  
  class { 'selinux':
    mode => 'disabled',
  }
  
  package {'php':
    ensure => 'installed',
  }
  
  
  archive { 'omeka-zip':
    ensure    => 'present',
    url       => "http://omeka.org/files/omeka-${omeka_ver}.zip",
    target    => '/var/www/html',
    extension => 'zip',
    checksum  => false,
  }

  
  package {'curl' : ensure => installed }
  package {'unzip': ensure => installed }
  package { 'java-1.7.0-openjdk.x86_64': ensure => 'installed', }
  
  class { '::apache::mod::php': }
  class { '::omeka::plugins': }
  
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
    owner   => 'apache',
    require => Archive['omeka-zip'],
  }
  
  if ($solrsearch) {
    class { '::omeka::solr':
      solr_binary    => $solr_binary,
      omeka_solrconf => $omeka_solrconf,
      omeka_home     => $omeka_home,
      omeka_ver      => $omeka_ver
    }
  }


}
