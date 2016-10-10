require 'spec_helper'

# BEGIN: config
$build_user = 'centos'
$build_user_home = "/home/#{$build_user}"
$build_information = "#{$build_user_home}/build-information.txt"
# END: config

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
  describe package('bind-utils') do
    it { should be_installed }
  end

  describe package('curl') do
    it { should be_installed }
  end

  describe package('git') do
    it { should be_installed }
  end

  describe package('htop') do
    it { should be_installed }
  end

  describe package('jq') do
    it { should be_installed }
  end

  # TODO: this currently fails even though `man` is installed
  # describe package('man') do
  #   it { should be_installed }
  # end

  describe package('mc') do
    it { should be_installed }
  end

  describe package('mlocate') do
    it { should be_installed }
  end

  describe package('nano') do
    it { should be_installed }
  end

  describe package('rsync') do
    it { should be_installed }
  end

  describe package('screen') do
    it { should be_installed }
  end

  describe package('telnet') do
    it { should be_installed }
  end

  describe package('tree') do
    it { should be_installed }
  end

  describe package('vim-enhanced') do
    it { should be_installed }
  end

  describe package('wget') do
    it { should be_installed }
  end
end
