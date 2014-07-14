require 'spec_helper'

describe 'eclipse::cpp' do
  it do
    should contain_package('Eclipse-CPP-Luna-R').with({
      :provider => 'higityr',
      :source   => 'http://mirrors.xmission.com/eclipse/technology/epp/downloads/release/luna/R/eclipse-cpp-luna-R-macosx-cocoa-x86_64.tar.gz',
    })
  end
end
