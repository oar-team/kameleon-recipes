class env::std::sudog5k {

  case $operatingsystem {
    'Debian': {
      include env::commonpackages::rake
      include env::commonpackages::rubyrspec
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
      file {
        '/etc/sudoers.d/sudo-g5k':
          ensure   => present,
          owner    => root,
          group    => root,
          mode     => '0440',
          source   => 'puppet:///modules/env/std/sudog5k/sudo-g5k.conf',
      }
    }
    default: {
      err "${operatingsystem} not suported."
    }
  }
}


