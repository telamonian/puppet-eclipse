require "open-uri"
require "puppet/provider/package"

Puppet::Type.type(:package).provide :eclipse_p2,
:parent => Puppet::Provider::Package do
  desc "Installs an Eclipse plugin using the Eclipse p2 provisioning app"
  
  confine  :operatingsystem => :darwin
  
  commands :chown => "/usr/sbin/chown"
  commands :curl  => "/usr/bin/curl"
  commands :ditto => "/usr/bin/ditto"
  commands :mv    => "/bin/mv"
  commands :rm    => "/bin/rm"
  commands :tar   => "/usr/bin/tar"

  def self.instances_by_name
    Dir.entries("/var/db").find_all { |f|
      f =~ /^\.puppet_eclipse_plugin_installed_/
    }.collect do |f|
      name = f.sub(/^\.puppet_eclipse_plugin_installed_/, '')
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
    installedPlugins = %x{#{eclipse_exec + " -application org.eclipse.equinox.p2.director -noSplash -listInstalledRoots"}}
    if @resource[:name] = installedPlugins.match(/#{@resource[:name]}/)
      {
        :name   => @resource[:name],
        :ensure => :installed
      }
    end
  end

  def install
    fail("Eclipse plugins must specify a plugin name (ie org.eclipse.sdk.ide)") unless @resource[:name]
    print 'heyho1\n'
    fail("Eclipse plugins must specify the absolute path of an eclipse installation dir") unless @resource[:install_options][:eclipse_dir]
    fail("Eclipse plugins must specify a repository url") unless @resource[:install_options][:repo]
    print 'heyho2\n'
    system(eclipse_exec + " -application org.eclipse.equinox.p2.director
    -repository #{@resource[:install_options][:repo]}
    -installIU #{@resource[:name]}
    -tag Add#{@resource[:name]}
    -profile SDKProfile")
    print 'heyho3\n'
    File.open(receipt_path, "w") do |t|
      t.print "name: '#{@resource[:name]}'\n"
      t.print "source: '#{@resource[:repo]}'\n"
    end
  end

  def uninstall
    system(eclipse_exec + " -application org.eclipse.equinox.p2.director
    -repository #{@resource[:install_options][:repo]}
    -uninstallIU #{@resource[:name]}
    -tag Add#{@resource[:name]}
    -profile SDKProfile")
  end

private

  def dir_path
    "/Applications/#{@resource[:name]}"
  end
  
  def receipt_path
      "/var/db/.puppet_compressed_dir_installed_#{@resource[:name]}"
  end
  
  def eclipse_exec
    File.join(@resource[:install_options][:eclipse_dir], 'eclipse')
  end

end
