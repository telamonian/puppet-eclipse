require 'spec_helper'

describe 'eclipse::plugins' do
  it do
    should contain_package('org.eclipse.cdt.feature.group').with({
    })
  end
end
