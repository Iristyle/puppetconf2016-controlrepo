## site.pp ##

# This file (/etc/puppetlabs/puppet/manifests/site.pp) is the main entry point
# used when an agent connects to a master and asks for an updated configuration.
#
# Global objects like filebuckets and resource defaults should go in this file,
# as should the default node definition. (The default node can be omitted
# if you use the console and don't define any other nodes in site.pp. See
# http://docs.puppetlabs.com/guides/language_guide.html#nodes for more on
# node definitions.)

## Active Configurations ##

# Disable filebucket by default for all File resources:
#http://docs.puppetlabs.com/pe/latest/release_notes.html#filebucket-resource-no-longer-created-by-default
File { backup => false }

# DEFAULT NODE
# Node definitions in this file are merged with node data from the console. See
# http://docs.puppetlabs.com/guides/language_guide.html#nodes for more on
# node definitions.

# The default node definition matches any node lacking a more specific node
# definition. If there are no other nodes in this file, classes declared here
# will be included in every node's catalog, *in addition* to any classes
# specified in the console for that node.

node default {
  # This is where you can declare classes for all nodes.
  # Example:
  #   class { 'my_class': }
}

node 'win2012-choco' {
  include role::chocolatey_server
}

site {
  puppylabs_app { 'puppylabs':
    version      => '0.0.1',
    nodes        => {
      Node['loadbalancer.vm'] => Profile::Loadbalancer['puppylabs'],
      Node['win2012-web-green-1'] => Profile::App['puppylabs-green-1'],
      Node['win2012-web-green-2'] => Profile::App['puppylabs-green-2'],
      Node['win2012-web-blue-1'] => Profile::App['puppylabs-blue-1'],
      Node['win2012-web-blue-2'] => Profile::App['puppylabs-blue-2'],
    }
  }
}
