# Public: Install Eclipse runtime binary into directory /Applications/${eclipse_dir}.
#
# Examples
#
#   include eclipse::plugin
define eclipse::plugin ($plugin_name, $repo, $eclipse_dir) {
  
#  $eclipse_dir_lstrip = regsubst($eclipse_dir, '^/', '')
#  $eclipse_dir_merged = regsubst($eclipse_dir_lstrip, '/', '_')
  
  package {"${plugin_name}_${eclipse_dir}":
    install_options => {'plugin_name' => $plugin_name, 'eclipse_dir' => $eclipse_dir, 'repo' => $repo},
    notify          => [ Exec["fix_permissions_${eclipse_dir}"] ],
    provider        => 'eclipse_p2',
    require         => [ Package["${eclipse_dir}"] ],
  }
}
