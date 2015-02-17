# Private class. Enabled by default via solrsearch => true
class omeka::solr (
  $solr_binary,
  $solrplugin       = 'http://omeka.org/wordpress/wp-content/uploads/Solr-Search-2.1.0.zip',
  $solr_ver         = '4.10.2',
  $omeka_ver,
  $omeka_home,
  $omeka_solrconf ) {

  $solr_war         = "/opt/solr/solr-${solr_ver}/dist/solr.war"

  class { '::solr':
    install_source => $solr_binary,
    config_file    => $omeka_solrconf
  }
  
  class { 'tomcat': install_from_source => false }
  
  tomcat::instance {'default': package_name => 'tomcat'} ->
  tomcat::service  {'default':
    use_jsvc => false, use_init => true, service_name => 'tomcat'
  } ->
  tomcat::config::server::connector { 'http':
    catalina_base    => '/usr/share/tomcat',
    protocol         => 'HTTP/1.1',
    port             => '8080',
    connector_ensure => 'present',
  }
  
  file { '/usr/share/tomcat/conf/Catalina/localhost/solr.xml':
    content => template('omeka/solr.xml.erb'),
    mode    => '0644',
  }

  archive { 'solrsearch-zip':
    ensure    => 'present',
    url       => $solrplugin,
    target    => "${omeka_home}/plugins",
    extension => 'zip',
    checksum  => false,
    require   => Archive['omeka-zip'],
  }
}
