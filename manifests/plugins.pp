# omeka plugins managed here
class omeka::plugins (
  $pdfsearch       = true,
  $fedoraconnector = true,
  $bagit = true,
) {

  # The plugin system dependencies

  # Fedora connector
  if ($fedoraconnector) {
    package { 'php-xml':       ensure => installed }
  }

  # PDF Search -- 
  # requires pdftotext, and poppler-utils specifically
  # and not the one that comes with xpdf
  if ($pdfsearch) {
    package { 'poppler-utils': ensure => installed }
  }

  if ($bagit) {
    # Install Archive_Tar php module -- on RHEL it's php-pear
    package { 'php-pear':      ensure => installed }
  }

}
