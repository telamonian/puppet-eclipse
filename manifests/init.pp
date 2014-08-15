# Public: Install Eclipse runtime binary into directory /Applications/${eclipse_dir}.
#
# Examples
#
#   include eclipse
class eclipse () {
  # sadly, we can't use parameters and automatic lookup with these hiera supplied variables, as the deep_merge stuff doesn't work correctly when hiera is called like that
  $eclipse_default_install = hiera_hash('eclipse_default_install')
  $eclipse_installs = hiera_hash('eclipse_installs', undef)
  $site_users = hiera_hash('site_users')
  $testy_test = hiera_hash('top_site_users')
  require java
  
  if $osfamily=='Darwin' {
	  property_list_key {'hashtest':
		  ensure     => present,
		  path       => "/Library/Java/JavaVirtualMachines/jdk1.7.0_${java::update_version}.jdk/Contents/Info.plist",
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
											'JVMVersion' => "1.7.0_${java::update_version}"},
		  value_type => 'hash'
	  }
  }
  
  if $eclipse_installs != undef {
  }
  else {
    info($site_users)
    info($testy_test)
    info($eclipse_default_install)
    create_resources(eclipse::install, $eclipse_default_install)
  }
  
  #create_resources(eclipse::plugin, hiera('eclipse::plugins::workspace_mechanic_info'))
}
