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


# SELinux tests
describe 'SELinux Policy' do
  end

  describe selinux do
    it { should be_permissive }
  end
end


# user tests
describe "User #{$build_user}" do
  describe user("#{$build_user}") do
    it { should exist }
    it { should have_home_directory "#{$build_user_home}" }
  end
end


# YUM repo tests
describe 'YUM repository: EPEL' do
  describe yumrepo('epel') do
    it { should exist }
    it { should be_enabled }
  end
end


# YUM package tests
describe 'YUM packages' do
  for package in $packages
    describe package("#{package}") do
      it { should be_installed }
    end
  end
end


  # TODO: this currently fails even though `man` is installed
  # describe package('man') do
  #   it { should be_installed }
  # end

# PIP package tests
describe 'PIP packages' do
  describe package('awscli') do
    it { should be_installed.by('pip') }
  end
end
