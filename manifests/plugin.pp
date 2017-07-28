
define omeka::plugin(
	$ensure  = 'present',
	$plugin  = $name,
  	$version = 'latest',
	$source  = undef,
) {
	$apache_docroot  = hiera('apache::docroot', "/var/www/html")
  	$omeka_version   = hiera('omeka::version', "2.5.1")
	$omeka_home      = "${apache_docroot}/omeka-${omeka_version}"
	$omeka_plugins   = "${omeka_home}/plugins"

	if $source == undef {
		archive { "${omeka_plugins}/${plugin}.zip":
			ensure       => $ensure,
			source       => "http://omeka.org/wordpress/wp-content/uploads/${plugin}-${version}.zip",
			extract_path => $omeka_plugins,
			extract      => true,
			creates      => "${omeka_plugins}/${plugin}",
			cleanup      => true,
		}  
	} else {
		$plugin_dir = "${omeka_plugins}/${plugin}"

		file { "$plugin_dir":
    		ensure  => 'directory',
		}

		archive { "${omeka_plugins}/${plugin}.zip":
			ensure       => $ensure,
			source       => $source,
			extract_path => $plugin_dir,
			extract      => true,
			creates      => $plugin_dir,
			cleanup      => true,
			requires     => File[$plugin_dir],
		}  
	}
}