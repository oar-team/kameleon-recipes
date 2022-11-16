class env::nfs::install_autofs_requirements(){

  if($::lsbdistcodename == 'bullseye') {
    env::common::g5kpackages {
      'autofs-g5k':
        ensure => '5.1.2-4',
        packages => ['autofs'],
        release => $::lsbdistcodename;
    }
  } else {
    package {
      'autofs':
        ensure => installed;
    }
  }

  service {
    'autofs':
      ensure => running,
      require => Package['autofs'];
  }
}
