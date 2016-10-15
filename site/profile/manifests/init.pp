application simple (
  String $version = '',
  String $lb_port  = '80',
) {
  profile::app { $name:
    version      => $version,
    export       => Http["app-${name}"],
  }
  profile::loadbalancer { $name:
    balancermembers => [Http["app-${name}"]],
    port            => $lb_port,
    require         => Http["app-${name}"],
    export          => Http["lb-${name}"],
  }
}
