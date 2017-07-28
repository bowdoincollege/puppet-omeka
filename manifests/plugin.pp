
define omeka::plugin(
	$ensure  = 'present',
	$plugin  = $name,
  	$version = 'latest',
	$source  = undef,
) {
	$apache_docroot  = hiera('apache::docroot', "/var/www/html")
  	$omeka_version   = hiera('omeka::version', "2.5.1")
	$omeka_home      = "${apache_docroot}/omeka-${omeka_version}"

	if $source == undef {
		$source = http://omeka.org/wordpress/wp-content/uploads/${plugin}-${version}.zip
	}

	#"http://omeka.org/wordpress/wp-content/uploads/${plugin}-${version}.zip",
	archive { "${omeka_home}/plugins/${plugin}.zip":
		ensure       => "${ensure}",
		source       => "${source}"
		extract_path => "${omeka_home}/plugins",
		extract      => true,
		creates      => "${omeka_home}/plugins/${plugin}",
		cleanup      => true,
	}  
}