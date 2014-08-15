require "open-uri"
require "puppet/provider/package"

Puppet::Type.type(:package).provide :eclipse_p2,
:parent => Puppet::Provider::Package do
  desc "Installs an Eclipse plugin using the Eclipse p2 provisioning app"
  
  has_feature :install_options
  
#  if RUBY_PLATFORM =~ /darwin/
#    commands :chown => "/usr/sbin/chown"
#    commands :curl  => "/usr/bin/curl"
#    commands :mv    => "/bin/mv"
#    commands :rm    => "/bin/rm"
#    commands :tar   => "/usr/bin/tar"
#  elsif RUBY_PLATFORM =~ /linux/
#    commands :chown => "/bin/chown"
#    commands :curl  => "/usr/bin/curl"
#    commands :mv    => "/bin/mv"
#    commands :rm    => "/bin/rm"
#    commands :tar   => "/bin/tar"
#  end
  
  def self.instances_by_name
    Dir.entries("/var/db").find_all { |f|
      f =~ /^\.puppet_eclipse_p2_installed_/
    }.collect do |f|
      name = f.sub(/^\.puppet_eclipse_p2_installed_/, '')
      yield name if block_given?
      name
    end
  end

  def self.instances
    instances_by_name.collect do |name|
      new(:name => name, :provider => :eclipse_p2, :ensure => :installed)
    end
  end

  def query
    #puts "eclipse_exec_#{eclipse_exec}"
    print @resource[:name]
    print @resource[:install_options][0]
    print @resource[:install_options][0]['eclipse_dir']
    if File.exists?(receipt_path)
      {
        :name   => @resource[:name],
        :ensure => :installed
      }
    end
  end  

# This version of the query function uses eclipse p2 to check installed plugins
# It's probably better to use the above query function, which is more similar to the function in the other Boxen package providers
#  def query
#    installedPlugins = %x{#{eclipse_exec + " -application org.eclipse.equinox.p2.director -noSplash -listInstalledRoots"}}
#    puts installedPlugins
#    if @resource[:name] == installedPlugins.match(/#{@resource[:name]}/)
#      {
#        :name   => @resource[:name],
#        :ensure => :installed
#      }
#    end
#  end

  def install
    eclipse_exec = File.join("/Applications", @resource[:install_options][0]['eclipse_dir'], "eclipse")
#    puts eclipse_exec
    fail("Eclipse plugins must specify a plugin name (ie org.eclipse.sdk.ide)") unless @resource[:install_options][0]['plugin_name']
    fail("Eclipse plugins must specify the absolute path of an eclipse installation dir") unless @resource[:install_options][0]['eclipse_dir']
    fail("Eclipse plugins must specify a repository url") unless @resource[:install_options][0]['repo']
    
    system(eclipse_exec + " -application org.eclipse.equinox.p2.director -noSplash -repository #{repo} -installIU #{IU} -tag installed_#{IU} -profile SDKProfile")
    File.open(receipt_path, "w") do |t|
      t.print "name: '#{@resource[:name]}'\n"
      t.print "source: '#{@resource[:install_options][0]['repo']}'\n"
    end
  end

  def uninstall
    eclipse_exec = File.join("/Applications", @resource[:install_options][0]['eclipse_dir'], "eclipse")
    system(eclipse_exec + " -application org.eclipse.equinox.p2.director -noSplash -repository #{repo} -uninstallIU #{IU} -tag removed_#{IU} -profile SDKProfile")
  end
  
private
  
  def receipt_path
    "/var/db/.puppet_eclipse_p2__installed_#{@resource[:name]}"
  end
  
  def repo
    @resource[:install_options][0]['repo']
  end
  
  # IU (installable unit) is eclipse-speak for the fully qualified name of the plugin
  def IU
    @resource[:install_options][0]['plugin_name']
  end

end
