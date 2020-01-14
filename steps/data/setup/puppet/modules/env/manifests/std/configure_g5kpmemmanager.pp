class env::std::configure_g5kpmemmanager {
  case $operatingsystem {
    'Debian': {
      case "${::lsbdistcodename}" {
        "buster" : {
          file {
            '/etc/systemd/system/g5k-pmem-manager.service':
              source => 'puppet:///modules/env/std/g5kpmemmanager/g5k-pmem-manager.service',
              ensure => file;
            '/usr/local/libexec/g5k-pmem-manager':
              source => 'puppet:///modules/env/std/g5kpmemmanager/g5k-pmem-manager',
              mode => '0755',
              ensure => file;
            '/etc/systemd/system/multi-user.target.wants/g5k-pmem-manager.service':
              ensure => link,
              target => '/etc/systemd/system/g5k-pmem-manager.service';
          }
        }
        default : {
          err "${operatingsystem} not supported."
        }
      }
    }
    default : {
      err "${operatingsystem} not supported."
    }
  }
}

