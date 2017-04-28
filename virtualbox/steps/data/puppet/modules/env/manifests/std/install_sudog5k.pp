class env::std::install_sudog5k {

  case $operatingsystem {
    'Debian': {
      require env::commonpackages::rake
      require env::commonpackages::rubyrspec
      require env::commonpackages::rsyslog
      exec {
        "retrieve_sudog5k":
          command  => "/usr/bin/wget --no-check-certificate -q https://www.grid5000.fr/packages/debian/sudo-g5k_all.deb -O /tmp/sudo-g5k_all.deb",
          creates  => "/tmp/sudo-g5k_all.deb";
      }
      package {
        "sudo-g5k":
          ensure   => installed,
          provider => dpkg,
          source   => "/tmp/sudo-g5k_all.deb",
          require  => [Exec["retrieve_sudog5k"]];
      }
    }
    default: {
      err "${operatingsystem} not suported."
    }
  }
  file {
    '/etc/sudo-g5k/id_rsa_sudo-g5k':
      ensure  => file,
      owner   => root,
      group   => root,
      mode    => '0600',
      source  => 'puppet:///modules/env/std/sudo-g5k/id_rsa_sudo-g5k',
      require => Package['sudo-g5k'];
  }
}
