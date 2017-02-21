class env::std::configure_activate_all_disks {

  require env::std::install_hwraid_apt_source

  case $operatingsystem {
    'Debian': {
      if "${::lsbdistcodename}" == "jessie" { 
        file {
          '/etc/systemd/system/activate-all-disks.service':
            source => 'puppet:///modules/env/std/activate_all_disks/activate-all-disks.service',
            ensure => file;
          '/usr/local/sbin/activate-all-disks':
            source => 'puppet:///modules/env/std/activate_all_disks/activate-all-disks',
            mode => '0755',
            ensure => file; 
          '/etc/systemd/system/multi-user.target.wants/activate-all-disks.service':
            ensure => link,
            target => '/etc/systemd/system/activate-all-disks.service';
        }
	package {
	  'megactl':
	  ensure => installed
	}
      }
      else {
        err "${operatingsystem} not supported."
      }
    }
    default: {
      err "${operatingsystem} not supported."
    }
  }
}

