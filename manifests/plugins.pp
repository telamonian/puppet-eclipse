# Public: Install Eclipse runtime binary into directory /Applications/${eclipse_dir}.
#
# Examples
#
#   include eclipse::plugins
class eclipse::plugins ($plugin_info) {
  require eclipse
  create_resources(classroom::plugin, $plugin_info)
}
