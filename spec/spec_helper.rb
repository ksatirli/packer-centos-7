require 'serverspec'
require 'net/ssh'

options = Net::SSH::Config.for(host, [])
options[:user] = ENV['TARGET_USER']
options[:keys] = ENV['TARGET_KEY']
options[:host_name] = ENV['TARGET_HOST']
options[:port] = ENV['TARGET_PORT']
options[:paranoid] = false unless ENV['SERVERSPEC_HOST_KEY_CHECKING'] =~ (/^(true|t|yes|y|1)$/i)

set :host,         options[:host_name]
set :ssh_options,  options
set :backend,      :ssh
set :display_sudo, true
set :request_pty,  true

# BEGIN: config
$build_user = 'centos'
$build_user_home = "/home/#{$build_user}"
$build_information = "#{$build_user_home}/build-information.txt"

$packages = [
  'bind-utils',
  'curl',
  'git',
  'htop',
  'jq',
  'mc',
  'mlocate',
  'nano',
  'python2-pip',
  'rsync',
  'screen',
  'telnet',
  'tree',
  'vim-enhanced',
  'wget'
]
# END: config
