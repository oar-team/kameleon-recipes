class env::base::packages () {

  $installed = [ 'bind9-host', 'python', 'ipython', 'ruby', 'curl', 'taktuk', 'bzip2', 'rsync', 'vim' ]

  package {
    $installed:
      ensure => installed;
  }
}
