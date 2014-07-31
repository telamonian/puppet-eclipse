# Public: Install Eclipse runtime binary into directory /Applications/${eclipse_dir}.
#
# Examples
#
#   include eclipse
class eclipse ($eclipse_dir, $eclipse_exec_src) {
  require java
  
  property_list_key {'hashtest':
	  ensure     => present,
	  path       => '/Library/Java/JavaVirtualMachines/jdk1.7.0_55.jdk/Contents/Info.plist',
	  key        => 'JavaVM',
	  value      => { 'JVMCapabilities' => ['JNI',
                                          'BundledApp',
									                        'WebStart',
									                        'Applets',
									                        'CommandLine'],
										'JVMMinimumFrameworkVersion' => '13.2.9',
										'JVMMinimumSystemVersion' => '10.6.0',
										'JVMPlatformVersion' => '1.7',
										'JVMVendor' => 'Oracle Corporation',
										'JVMVersion' => '1.7.0_55'},
	  value_type => 'hash'
  }
  
  package {$eclipse_dir:
    provider => 'compressed_dir',
    install_options => [{'eclipse_dir' => $eclipse_dir }],
    source   => $eclipse_exec_src
  }
  
  create_resources(eclipse::plugin, hiera('eclipse::cplugins::workspace_mechanic_info'))
}
