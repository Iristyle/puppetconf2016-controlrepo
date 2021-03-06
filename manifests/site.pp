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

node 'loadbalancer' {
  profile::loadbalancer { 'empty_loadbalancer':
    balancermembers => [
      {
        host => 'win2012-web-green-1',
        # uh-oh, how do we get this dynamically?
        # well, we could use exported resources, but thats a bit complicated
        # / hard to enforce ordering
        # ip => '',
        port => '80'
      }
    ],
  }
}

node 'win2012-choco' {
  include role::chocolatey_server
}

node /^win2012-web-.*$/ {
  profile::app { 'puppylabs':
    version => '0.0.1',
  }
}
