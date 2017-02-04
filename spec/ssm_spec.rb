require 'spec_helper'

# build information tests
describe 'Build Information' do
  describe file("#{$build_information}") do
    it { should exist }
    it { should_not be_directory }
    it { should_not be_symlink }
    it { should_not be_executable }
    it { should be_readable }
    its(:size) { should > 0 }
  end
end

# YUM package tests
describe 'YUM packages' do
  describe package('amazon-ssm-agent') do
    it { should be_installed }
  end
end
