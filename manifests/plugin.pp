# Public: Install Eclipse runtime binary into directory /Applications/${eclipse_dir}.
#
# Examples
#
#   include eclipse::plugin
define eclipse::plugin ($plugin_name, $repo, $eclipse_dir) {
  require eclipse
  package {"${plugin_name}_${eclipse_dir}":
    provider => 'eclipse_p2',
    install_options => {'plugin_name' => $plugin_name, 'eclipse_dir' => $eclipse_dir, 'repo' => $repo}
  }
}
