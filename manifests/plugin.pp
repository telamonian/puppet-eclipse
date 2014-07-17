# Public: Install Eclipse runtime binary into directory /Applications/${eclipse_dir}.
#
# Examples
#
#   include eclipse::plugin
define eclipse::plugin ($name, $repo, $eclipse_dir) {
  require eclipse
  package {$name:
    name => $name,
    provider => 'eclipse_p2',
    source => $repo,
    install_options => {'eclipse_dir' => $eclipse_dir, 'repo' => $repo}
  }
}
