define profile::loadbalancer (
  $balancermembers,
  Array $lb_options     = ['forwardfor', 'http-server-close', 'httplog'],
  String $ipaddress     = '0.0.0.0', # $::ipaddress,
  String $balance_mode  = 'roundrobin',
  String $port          = '80',
){
  #This role would be made of all the profiles that need to be included to make a webserver work
  #All roles should include the base profile
  include profile::base
  include profile::haproxy

  # listener for our node
  haproxy::listen {"httpcluster-${name}":
    collect_exported => false,
    ipaddress        => $ipaddress,
    mode             => 'http',
    options          => {
      'cookie'  => 'SERVERID insert indirect',
      'option'  => $lb_options,
      'balance' => $balance_mode,
    },
    ports            => $port,
  }

  # listen on port 9000 for stats
  haproxy::listen { 'stats':
    ipaddress => $ipaddress,
    ports     => '9000',
    options   => {
      'mode'  => 'http',
      'stats' => [
        'uri /',
        'auth admin:puppetlabs'
      ],
    },
  }

  # Create a balancermember for each web node
  $balancermembers.each |$member| {
    haproxy::balancermember { $member['host']:
      listening_service => "httpcluster-${name}",
      server_names      => $member['host'],
      ipaddresses       => $member['ip'],
      ports             => $member['port'],
      options           => "check",
      # NOTE: cookie option cannot be used with roundrobin
      # cookie ${member['host']}
    }
  }
}

# exists for health check
Profile::Loadbalancer produces Http {
  host => $::fqdn,
  ip   => $::ipaddress,
  port => $port,
  status_codes => [200, 302],
}
