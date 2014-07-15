require 'spec_helper'

describe 'eclipse' do
  it do
    should contain_package('eclipse').with({
      :source   => 'http://download.eclipse.org/eclipse/downloads/drops4/R-4.4-201406061215/eclipse-platform-4.4-macosx-cocoa-x86_64.tar.gz',
      :provider => 'compressed_dir'
    })
  end
end
