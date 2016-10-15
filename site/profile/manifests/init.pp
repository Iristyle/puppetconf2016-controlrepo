application puppylabs_app (
  String $version = '',
  String $lb_port  = '80',
  String $cluster_name = '',
) {
  if ($cluster_name == '') {
    fail("A cluster name must be specified for App[${name}].")
  }

  # filter by current cluster - this is an app name, not node name
  $cluster_filter = "^puppylabs-${cluster_name}-\d+$"

  # Collect the titles of all Web components declared in nodes.
  $app_components = collect_component_titles($nodes, Profile::App).filter |$comp_name| {
    $comp_name =~ $cluster_filter
  }

  # Verify there is at least one app in the cluster
  if (size($app_components) == 0) {
    fail("Found no web component for App[${name}] in cluster ${cluster_name}. At least one is required")
  }

  # For each of these declare the component and create an array of the exported
  # Http resources from them for the load balancer.
  $app_https = $app_components.map |$comp_name| {
    # Compute the Http resource title for export and return.
    $http = Http["app-${comp_name}"]
    # Declare the web component.
    profile::app { $comp_name:
      version      => $version,
      cluster_name => $cluster_name,
      export       => $http,
    }

    # Return the $http resource for the array.
    $http
  }

  profile::loadbalancer { $name:
    balancermembers => $app_https,
    port            => $lb_port,
    require         => $app_https,
    export          => Http["lb-${name}"],
  }
}
