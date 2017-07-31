# omeka themes managed here

define omeka::theme(
  $ensure  = 'present',
  $version = 'latest',
  $source  = undef,
) {
  $apache_docroot  = hiera('apache::docroot', "/var/www/html")
  $omeka_version   = hiera('omeka::version', "2.5.1")

  $omeka_home      = "${apache_docroot}/omeka-${omeka_version}"
  $omeka_themes    = "${omeka_home}/themes"

  if $source == undef {
  	$url = "http://omeka.org/wordpress/wp-content/uploads/${name}-${version}.zip"
  } else {
  	$url = $source
  }
  
  archive { "${omeka_themes}/${name}.zip":
  	ensure       => $ensure,
  	source       => $url,
  	extract_path => $omeka_themes,
  	extract      => true,
  	creates      => "${omeka_themes}/${name}/theme.ini",
  	cleanup      => true,
  }  
}

class omeka::themes($themes) {
  create_resources('omeka::theme', $themes)
}

