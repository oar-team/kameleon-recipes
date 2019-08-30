class env::std::configure_g5kdiskmanager {

  require env::std::install_hwraid_apt_source

  case $operatingsystem {
    'Debian': {
      case "${::lsbdistcodename}" {
        "jessie", "stretch", "buster" : {
          file {
            '/etc/systemd/system/g5k-disk-manager.service':
              source => 'puppet:///modules/env/std/g5kdiskmanager/g5k-disk-manager.service',
              ensure => file;
            '/usr/local/libexec/':
              ensure   => directory,
              mode     => '0755',
              owner    => 'root',
              group    => 'root';
            '/usr/local/libexec/g5k-disk-manager':
              source => 'puppet:///modules/env/std/g5kdiskmanager/g5k-disk-manager',
              mode => '0755',
              ensure => file;
            '/etc/systemd/system/multi-user.target.wants/g5k-disk-manager.service':
              ensure => link,
              target => '/etc/systemd/system/g5k-disk-manager.service';
          }
          package {
            'megactl':
              ensure => installed,
              require  => [Apt::Source['hwraid.le-vert.net'], Exec['apt_update']]
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

