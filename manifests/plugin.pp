
define omeka::plugin(
	$ensure  = 'present',
	$plugin  = $name,
  	$version = 'latest'
) {
	$apache_docroot  = hiera('apache::docroot', "/var/www/html")
  	$omeka_version = hiera('omeka::version', "2.5.1")
	$omeka_home      = "${apache_docroot}/omeka-${omeka_version}"

	archive { "${name}_zip":
		ensure       => 'present',
		source       => "http://omeka.org/wordpress/wp-content/uploads/${name}-${version}.zip",
		extract_path => "${omeka_home}/plugins",
		extract      => true,
		creates      => "${omeka_home}/plugins/${name}",
		cleanup      => true,
	}  
}