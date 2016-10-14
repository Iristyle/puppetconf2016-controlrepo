class profile::iis {

  $iis_features = [
    'Web-WebServer',
    'Web-Http-Errors',
    'Web-Http-Logging',
    'Web-Asp-Net45',
    'NET-Framework-45-ASPNET',
  ]

  windowsfeature{ $iis_features:
    ensure => present,
    # installmanagementtools => true,
  } ~>

  # Remove default binding by removing default website
  # (so it can be used by something else)
  dsc_xwebsite{'Default Web Site':
    dsc_ensure       => 'Absent',
    dsc_name         => 'Default Web Site',
    dsc_applicationpool => 'DefaultAppPool',
  }
}
