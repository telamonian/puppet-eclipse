# Public: Install Eclipse runtime binary into directory ${eclipse_dir}.
#
# Examples
#
#   don't call this directly
define eclipse::install ($eclipse_dir, $eclipse_app_src, $plugin_info=undef) {
  
  exec { "fix_permissions_${eclipse_dir}":
    command     => "chown -R ${::boxen_user}:${boxen::config::group} ${eclipse_dir}",
    logoutput   => 'on_failure',
    refreshonly => true,
    user        => root,
  }
  
  package{ "${eclipse_dir}":
    install_options => [{'eclipse_dir' => $eclipse_dir }],
    notify   => [ Exec["fix_permissions_${eclipse_dir}"] ],
    provider => 'compressed_dir',
    source   => $eclipse_app_src
  }
  
  # the lengths I will go to to avoid future parser or custom functions
  # these lines add a suffix to every key in a hash in order to differentiate the Plugin['name'] resources of the individual eclipse installs
  $workspace_mechanic_info = hiera_hash('eclipse::workspace_mechanic_info')
  $workspace_mechanic_keys = keys($workspace_mechanic_info)
  $workspace_mechanic_keys_suffixed = suffix($workspace_mechanic_keys, $eclipse_dir)
  $workspace_mechanic_values = values($workspace_mechanic_info)
  $workspace_mechanic_info_suffixed = hash(flatten(zip($workspace_mechanic_keys_suffixed, $workspace_mechanic_values)))
  
  create_resources(eclipse::plugin, $workspace_mechanic_info_suffixed, {eclipse_dir => $eclipse_dir})
  
  if $plugin_info != undef {
    $plugin_keys = keys($plugin_info)
    $plugin_keys_suffixed = suffix($plugin_keys, $eclipse_dir)
    $plugin_values = values($plugin_info)
    $plugin_info_suffixed = hash(flatten(zip($plugin_keys_suffixed, $plugin_values)))
  
    create_resources(eclipse::plugin, $plugin_info_suffixed, {eclipse_dir => $eclipse_dir})
  }
}
