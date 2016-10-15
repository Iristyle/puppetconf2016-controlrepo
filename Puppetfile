forge "http://forge.puppetlabs.com"

# Modules from the Puppet Forge
# Versions should be updated to be the latest at the time you start
mod "puppetlabs/stdlib", '4.12.0'
mod "puppetlabs/concat", '2.2.0'
mod "puppetlabs/chocolatey", '2.0.0'
mod "puppetlabs/haproxy", '1.5.0'
mod "puppetlabs/dsc", '1.1.0'
mod "puppetlabs/reboot", '1.2.1'
mod "puppetlabs/acl", '1.1.2'
mod "puppetlabs/powershell", '2.0.3'
mod "puppetlabs/registry", '1.1.3'
mod "puppetlabs/app_modeling", '0.2.0'

# community modules
mod "puppet/windowsfeature", '2.0.0'

# Modules from Git
# Examples: https://github.com/puppetlabs/r10k/blob/master/doc/puppetfile.mkd#examples

# custom fork of Choco simple server module that uses DSC instead of puppet/iis
# as that modules requires powershell module < 2
mod 'chocolatey_server',
  :git => 'https://github.com/Iristyle/puppet-chocolatey_server',
  :commit => '772707df3b47917628f485ecbd65cce6a4fc978b'

#mod 'apache',
#  :git    => 'https://github.com/puppetlabs/puppetlabs-apache',
#  :branch => 'docs_experiment'
