require 'spec_helper'

describe 'eclipse' do
  it do
    should contain_package('eclipse-luna-cpp-R').with({
      :source   => 'http://mirrors.xmission.com/eclipse/technology/epp/downloads/release/luna/R/eclipse-cpp-luna-R-macosx-cocoa-x86_64.tar.gz',
      :provider => 'appdmg_eula'
    })
  end
end
