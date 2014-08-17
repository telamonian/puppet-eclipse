require "open-uri"
require "puppet/provider/package"

Puppet::Type.type(:package).provide :compressed_dir,
:parent => Puppet::Provider::Package do
  desc "Installs a compressed dir. Supports zip, tar.gz, tar.bz2"

#  FLAVORS should be defined already in the vanilla boxen provider compressed_app.rb, in which case the following line will produce a warning
  FLAVORS = %w(zip tgz tar.gz tbz tbz2 tar.bz2)

  has_feature :install_options

  if RUBY_PLATFORM =~ /darwin/
    commands :chown => "/usr/sbin/chown"
    commands :curl  => "/usr/bin/curl"
  #  commands :ditto => "/usr/bin/ditto"
    commands :mv    => "/bin/mv"
    commands :rm    => "/bin/rm"
    commands :tar   => "/usr/bin/tar"
  elsif RUBY_PLATFORM =~ /linux/
    commands :chown => "/bin/chown"
    commands :curl  => "/usr/bin/curl"
  #  commands :ditto => "/usr/bin/ditto"
    commands :mv    => "/bin/mv"
    commands :rm    => "/bin/rm"
    commands :tar   => "/bin/tar"
  end
  
  def self.instances_by_name
    Dir.entries("/var/db").find_all { |f|
      f =~ /^\.puppet_compressed_dir_installed_/
    }.collect do |f|
      name = f.sub(/^\.puppet_compressed_dir_installed_/, '')
      yield name if block_given?
      name
    end
  end

  def self.instances
    instances_by_name.collect do |name|
      new(:name => name, :provider => :compressed_dir, :ensure => :installed)
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

  def install
    fail("Compressed dirs must specify a package name") unless @resource[:name]
    fail("Compressed dirs must specify a package source") unless @resource[:source]
    fail("Unknown flavor #{flavor}") unless FLAVORS.include?(flavor)
    
    FileUtils.mkdir_p '/opt/boxen/cache'

    %x(/usr/bin/curl -o #{cached_path} -C - -k -L -s --url #{@resource[:source]})
#    curl "-o", cached_path, "-C", "-", "-k", "-L", "-s", "--url", @resource[:source]
#    print @resource[:source]
#    print "-Lqo"
#    print cached_path
    #curl @resource[:source],"-C", "-", "-Lqo", cached_path
      
    rm "-rf", dir_path
    
    FileUtils.mkdir_p dir_path
    case flavor
    # TODO: for now, this provider can't deal with files compressed with PKZip (.zip files), as there is no ditto on linux systems
    # when 'zip'
    #  ditto "-xk", cached_path, "/Applications"
    when 'tar.gz', 'tgz'
      tar "-zxf", cached_path, "-C", dir_path, "--strip-components", "1"
    when 'tar.bz2', 'tbz', 'tbz2'
      tar "-jxf", cached_path, "-C", dir_path, "--strip-components", "1"
    else
      fail "Can't decompress flavor #{flavor}"
    end

    chown "-R", "#{Facter[:boxen_user].value}:#{Facter[:boxen_group].value}", dir_path

    File.open(receipt_path, "w") do |t|
      t.print "name: '#{merged_name}'\n"
      t.print "source: '#{@resource[:source]}'\n"
    end
  end

  def uninstall
    rm "-rf", dir_path
    rm "-f", receipt_path
  end

private

  def flavor
    @resource[:flavor] || @resource[:source].match(/\.(#{FLAVORS.join('|')})$/i){|m| m[1] }
  end
  
  def merged_name
    @resource[:name][0]=='/' ? @resource[:name].gsub('/','_')[1..-1] : @resource[:name].gsub('/','_')
  end
  
  def dir_path
    @resource[:name]
  end
  
  def cached_name
    File.split(@resource[:source])[1].split('.')[0]
  end
  
  def cached_path
    "/opt/boxen/cache/#{cached_name}.#{flavor}"
  end

  def receipt_path
    "/var/db/.puppet_compressed_dir_installed_#{merged_name}"
  end

end
