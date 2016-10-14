class profile::dotnet_45 {
  $dotnet_features = [
    'NET-Framework-45-Features',
    'NET-Framework-45-Core',
  ]

  windowsfeature{ $dotnet_features:
    ensure => present,
  }
}
