class profile::chocolatey_server {

  # https://github.com/chocolatey/puppet-chocolatey_server
  # apikey is chocolateyrocks
  # https://github.com/chocolatey/simple-server/blob/99b109c77725911d602a687bb2a975fecdffa833/src/SimpleChocolateyServer/Web.config#L73
  include chocolatey_server
}
