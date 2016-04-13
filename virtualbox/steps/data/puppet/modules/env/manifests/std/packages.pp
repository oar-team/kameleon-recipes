class env::std::packages () {

  # bootlogd: debug purpose
  $utils = [ 'bootlogd', 'xauth' ]

  $installed = [ $utils ]

  package {
    $installed:
      ensure => installed;
  }
}

