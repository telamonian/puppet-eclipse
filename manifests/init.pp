# Public: Install Eclipse runtime binary into directory /Applications/${eclipse_dir}.
#
# Examples
#
#   include eclipse
class eclipse ($eclipse_dir='eclipse', $eclipse_exec_src='http://download.eclipse.org/eclipse/downloads/drops4/R-4.4-201406061215/eclipse-platform-4.4-macosx-cocoa-x86_64.tar.gz') {
  require java
  
  property_list_key { 'JavaVM':
    JVMCapabilities => ['JNI',
                        'BundledApp',
                        'WebStart',
                        'Applets',
                        'CommandLine']}
  
  package {'eclipse':
    provider => 'compressed_dir',
    install_options => [{'eclipse_dir' => $eclipse_dir }],
    source   => $eclipse_exec_src
  }
}
