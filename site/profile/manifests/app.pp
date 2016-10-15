define profile::app (
  $app_pool      = 'PuppyLabs',
  $app_site      = 'PuppyLabs',
  $app_root      = 'C:/inetpub/wwwroot',
  $port          = 80,
  $lb_port       = 80,
  $version       = '',
  $cluster_name  = '',
){

  include profile::dotnet_45
  include profile::iis

  $app_location = "${app_root}/${app_site}"

  $stop_site_if_necessary_script = @("END"/)
  choco list --localonly puppylabs |
    ? { \$_ -match '^(\\d+)\\s+packages\\s+installed' } |
    # no packages yet installed
    % { if (\$Matches[1] -eq 0 ) { exit 1 } }

  # is the version installed the one we're looking for?
  choco list --localonly puppylabs --version $version |
    ? { \$_ -match '^(\\d+)\\s+packages\\s+installed' } |
    # we already have this version installed
    % { if (\$Matches[1] -ne 0) { exit 1 } }

  exit 0
  |- END

  exec { "stop_${app_site}_if_necessary":
    provider => powershell,
    # if puppylabs is installed, but its not the requested version
    onlyif => $stop_site_if_necessary_script,
    command => "Import-Module WebAdministration; Get-Website -Name ${app_site} | Stop-Website"
  }

  package { 'puppylabs':
    ensure   => $version,
    provider => 'chocolatey',
    # in case using UNC path instead of simple server
    # source   => '\\unc\source\packages',
    source          => 'http://win2012-choco/chocolatey',
    install_options => [ '-params', '"', "INSTALLDIR=${app_root}", '"', '--allow-downgrade' ],
    require => Exec["stop_${app_site}_if_necessary"]
  }

  # gets picked up in Web.config template
  $customErrors = 'Off'

  # should pick up:
  # customErrors
  # version
  # cluster_name
  file { "${app_location}/Web.config":
    ensure  => present,
    content => template("profile/Web.Config.erb"),

  } ~>

  # application in iis
  dsc_xwebapppool { $app_pool:
    dsc_ensure => 'Present',
    dsc_name => $app_pool,
    dsc_enable32bitapponwin64 => true,
    dsc_managedruntimeversion => 'v4.0',
    dsc_managedpipelinemode => 'Integrated',
  } ~>

  dsc_xwebsite{ $app_site:
    dsc_ensure       => 'Present',
    dsc_name         => $app_site,
    dsc_physicalpath => regsubst($app_location, '/', '\\','G'),
    dsc_applicationpool => $app_pool,
    dsc_bindinginfo => [
      {
        protocol => 'http',
        port => $port,
        ipaddress => '*',
      }
    ],
    require   => Package['puppylabs'],
  }

  exec { "start_${app_site}_if_necessary":
    provider => powershell,
    onlyif => "Import-Module WebAdministration; if ((Get-Website -Name ${app_site}).State -ne 'Started') { exit 0 }; exit 1",
    command => "Import-Module WebAdministration; Start-WebSite ${app_site}",
    require => Dsc_xwebsite[$app_site]
  }

  # should not be necessary under default C:\inetpub\wwwroot\ because of inherited perms
  # acl { "${app_location}":
  #   purge                       => true,
  #   inherit_parent_permissions  => false,
  #   permissions =>
  #   [
  #     { identity => 'Administrators', rights => ['full'] },
  #     { identity => 'IIS_IUSRS', rights => ['read'] },
  #     { identity => 'IUSR', rights => ['read'] },
  #     { identity => "IIS APPPOOL\\${app_pool}", rights => ['read', 'execute'] },
  #   ],
  #   require => Dsc_xwebapppool[$app_pool],
  # }
}

Profile::App produces Http {
  # TODO: simpler for Windows? ip   => $ipaddress,
  ip   => $interface ? { /\S+/ => $::networking['interfaces'][$interface]['ip'], default => $::ipaddress },
  port => $port,
  host => $::fqdn,
  status_codes => [200, 302],
}
