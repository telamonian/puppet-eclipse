# Public: Install Eclipse runtime binary into directory ${eclipse_dir}.
#
# Examples
#
#   don't call this directly
define eclipse::install ($eclipse_dir, $eclipse_app_src, $plugin_info) {
  package{ "${eclipse_dir}":
    provider => 'compressed_dir',
    install_options => [{'eclipse_dir' => $eclipse_dir }],
    source   => $eclipse_app_src
  }
  
  create_resources(eclipse::plugin, hiera_hash('workspace_mechanic_info'), {eclipse_dir => $eclipse_dir})
}
