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
    if File.exists?(receipt_path)
      {
        :name   => merged_name,
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
    fail("Eclipse plugins must specify a plugin name (ie org.eclipse.sdk.ide)") unless @resource[:install_options][0]['plugin_name']
    fail("Eclipse plugins must specify the absolute path of an eclipse installation dir") unless @resource[:install_options][0]['eclipse_dir']
    fail("Eclipse plugins must specify a repository url") unless @resource[:install_options][0]['repo']
    
    system(eclipse_exec + " -application org.eclipse.equinox.p2.director -noSplash -repository #{repo} -installIU #{eclipse_iu} -tag installed_#{eclipse_iu} -profile SDKProfile")
    File.open(receipt_path, "w") do |t|
      t.print "name: '#{merged_name}'\n"
      t.print "source: '#{@resource[:install_options][0]['repo']}'\n"
    end
  end

  def uninstall
    system(eclipse_exec + " -application org.eclipse.equinox.p2.director -noSplash -repository #{repo} -uninstallIU #{eclipse_iu} -tag removed_#{eclipse_iu} -profile SDKProfile")
  end
  
private
  
  def receipt_path
    "/var/db/.puppet_eclipse_p2__installed_#{merged_name}"
  end
  
  def eclipse_dir
    @resource[:install_options][0]['eclipse_dir']
  end
  
  def merged_eclipse_dir
    eclipse_dir[0]=='/' ? eclipse_dir.gsub('/','_')[1..-1] : eclipse_dir.gsub('/','_')
  end
  
  def eclipse_exec
    File.join(@resource[:install_options][0]['eclipse_dir'], "eclipse")
  end
  
  # eclipse_iu (installable unit) is eclipse-speak for the fully qualified name of the plugin
  def eclipse_iu
    @resource[:install_options][0]['plugin_name']
  end
  
  def merged_name
    [eclipse_iu, merged_eclipse_dir].join('_')
  end
  
  def repo
    @resource[:install_options][0]['repo']
  end

end
