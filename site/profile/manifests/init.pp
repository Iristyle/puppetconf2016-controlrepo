application puppylabs_app (
  String $version = '',
  String $lb_port  = '80',
) {

  # Collect the titles of all Web components declared in nodes.
  $app_components = collect_component_titles($nodes, Profile::App)
  # Verify there is at least one app
  if (size($app_components) == 0) {
    fail("Found no web component for App[${name}]. At least one is required")
  }

  # For each of these declare the component and create an array of the exported
  # Http resources from them for the load balancer.
  $app_https = $app_components.map |$comp_name| {
    # Compute the Http resource title for export and return.
    $http = Http["app-${comp_name}"]
    # Declare the web component.
    profile::app { $comp_name:
      version      => $version,
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
