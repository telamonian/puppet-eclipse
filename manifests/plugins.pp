# Public: Install Eclipse runtime binary into directory /Applications/${eclipse_dir}.
#
# Examples
#
#   include eclipse::plugins
class eclipse::plugins ($plugin_info) {
  require eclipse
  notify{"plugin_info is: {$plugin_info}":}
  debug($plugin_info)
  create_resources(eclipse::plugin, $plugin_info)
}
