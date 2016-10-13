class profile::base {

  case downcase($::osfamily) {
    'windows': {

      # installs chocolatey package manager on all Windows versions
      include chocolatey

      # and adds the internal feed
      chocolateysource {'internal-choco-feed':
        ensure   => present,
        location => 'http://win2012-choco/chocolatey/Packages',
        priority => 1,
      }
    }
  }

}
