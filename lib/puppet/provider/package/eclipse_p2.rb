require "open-uri"
require "puppet/provider/package"

Puppet::Type.type(:package).provide :eclipse_p2,
:parent => Puppet::Provider::Package do
  desc "Installs an Eclipse plugin using the Eclipse p2 provisioning app"

  confine  :operatingsystem => :darwin

  commands :chown => "/usr/sbin/chown"
  commands :curl  => "/usr/bin/curl"
  commands :ditto => "/usr/bin/ditto"
  commands :eclipse => File.join(@resource[:eclipse_dir], "/eclipse")
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
    cmd = File.join(@resource[:eclipse_dir], "/eclipse"
    installedPlugins = %x[#{cmd + "-application org.eclipse.equinox.p2.director -noSplash -listInstalledRoots"}]
    if @resource[:name] = installedPlugins.match(/#{@resource[:name]}/)
      {
        :name   => @resource[:name],
        :ensure => :installed
      }
    end
  end

  def install
    fail("Eclipse plugins must specify a plugin name (ie org.eclipse.sdk.ide)") unless @resource[:name]
    fail("Eclipse plugins must specify the absolute path of an eclipse installation dir") unless @resource[:eclipse_dir]
    fail("Eclipse plugins must specify a repository url") unless @resource[:repo]
    
    eclipse "-application org.eclipse.equinox.p2.director
    -repository #{@resource[:repo]}
    -installIU #{@resource[:name]}
    -tag Add#{@resource[:name]}
    -profile SDKProfile"
  end

  def uninstall
    eclipse "-application org.eclipse.equinox.p2.director
    -repository #{@resource[:repo]}
    -uninstallIU #{@resource[:name]}
    -tag Add#{@resource[:name]}
    -profile SDKProfile"
  end

private

  def dir_path
    "/Applications/#{@resource[:name]}"
  end

end
