# omeka themes managed here
class omeka::themes(
  $themes,
) {

  create_resources('omeka::theme', $themes)
}
