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
    installedPlugins = %x{#{eclipse_exec + " -application org.eclipse.equinox.p2.director -noSplash -listInstalledRoots"}}
    if @resource[:name] == installedPlugins.match(/#{@resource[:name]}/)
      {
        :name   => @resource[:name],
        :ensure => :installed
      }
    end
  end

  def install
    options = install_options
    
    File.open("/Users/telv/ruby.log", 'w') do |t|
      t.print "name: '#{@resource[:name]}'\n"
      t.print "source: '#{options[:repo]}'\n"
      t.print "install options hash: '#{options}'\n"
      t.print "whole hash: '#{@resource}'\n"
    end
    fail("Eclipse plugins must specify a plugin name (ie org.eclipse.sdk.ide)") unless @resource[:name]
    info("some_info")
    Puppet.debug("#{options}")
    function_notice(["Desired is: '#{@resource}' "])
    debug("#{options}")
    fail("Eclipse plugins must specify the absolute path of an eclipse installation dir") unless options[:eclipse_dir]
    fail("Eclipse plugins must specify a repository url") unless options[:repo]
    
    system(eclipse_exec + " -application org.eclipse.equinox.p2.director -repository #{options[:repo]} -installIU #{@resource[:name]} -tag Add#{@resource[:name]}   -profile SDKProfile")
    print 'heyho3\n'
    File.open(receipt_path, "w") do |t|
      t.print "name: '#{@resource[:name]}'\n"
      t.print "source: '#{options[:repo]}'\n"
    end
  end

  def uninstall
    options = install_options
    
    system(eclipse_exec + " -application org.eclipse.equinox.p2.director
    -repository #{options[:repo]}
    -uninstallIU #{@resource[:name]}
    -tag Add#{@resource[:name]}
    -profile SDKProfile")
  end

  def install_options
    puts @resource[:name]
    print @resource[:name]
    puts "#{@resource[:name]}"
    print "#{@resource[:name]}"
    puts @resource[:source]
    print @resource[:source]
    puts "#{@resource[:source]}"
    print "#{@resource[:source]}"
    puts @resource
    print @resource
    puts "#{@resource}"
    print "#{@resource}"
    puts @resource[:install_options]
    print @resource[:install_options]
    puts "#{@resource[:install_options]}"
    print "#{@resource[:install_options]}"
    join_options(@resource[:install_options])
  end

def collect_options(options)
  return unless options

  newOpts = Hash.new

  options.each do |val|
    case val
    when Hash
      val.keys.each do |key|
        puts key
        newOpts[key] = val[key]
      end
    else
      newOpts[val] = val
    end
  end

  symbolizehash(newOpts)
end
  
#  def join_options(options)
#    return unless options
#
#    options.collect do |val|
#      case val
#        when Hash
#          val.keys.sort.collect do |k|
#            "#{k}=#{val[k]}"
#          end
#        else
#          val
#      end
#    end.flatten
#  end
  
private

  def dir_path
    "/Applications/#{@resource[:name]}"
  end
  
  def receipt_path
      "/var/db/.puppet_compressed_dir_installed_#{@resource[:name]}"
  end
  
  def eclipse_exec
    "/Applications/eclipse/eclipse"
    #File.join(options[:eclipse_dir], 'eclipse')
  end

end
