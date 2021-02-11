class env::std::configure_g5kdiskmanagerbackend {

  require env::std::install_hwraid_apt_source
  require env::std::configure_g5kmanager

  case $operatingsystem {
    'Debian': {
      case "${::lsbdistcodename}" {
        "stretch", "buster", "bullseye" : {
          file {
            '/etc/systemd/system/g5k-disk-manager-backend.service':
              source => 'puppet:///modules/env/std/g5k-manager/g5k-disk-manager-backend.service',
              ensure => file;
            '/usr/local/libexec/g5k-disk-manager-backend':
              source => 'puppet:///modules/env/std/g5k-manager/g5k-disk-manager-backend',
              mode => '0755',
              ensure => file;
            '/etc/systemd/system/multi-user.target.wants/g5k-disk-manager-backend.service':
              ensure => link,
              target => '/etc/systemd/system/g5k-disk-manager-backend.service';
          }
        }
        default : {
          err "${::lsbdistcodename} not supported."
        }
      }
    }
    default : {
      err "${operatingsystem} not supported."
    }
  }
}

