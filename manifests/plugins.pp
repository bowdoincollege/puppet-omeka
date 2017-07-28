# omeka plugins managed here
class omeka::plugins(
  $plugins,
) {
  $pdfsearch       = false

  # The plugin system dependencies

  # PDF Search -- 
  # requires pdftotext, and poppler-utils specifically
  # and not the one that comes with xpdf
  if ($pdfsearch) {
    package { 'poppler-utils': ensure => installed }
  }

  create_resources('omeka::plugin' $plugins)
}
