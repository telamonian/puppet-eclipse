# Public: Install Eclipse runtime binary into directory /Applications/${eclipse_dir}.
#
# Examples
#
#   include eclipse::plugins
class eclipse::plugins ($plugin_info, $eclipse_dir) {
  create_resources(eclipse::plugin, $plugin_info, {eclipse_dir => $eclipse_dir})
}
