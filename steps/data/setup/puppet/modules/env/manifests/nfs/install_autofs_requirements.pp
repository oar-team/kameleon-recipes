class env::nfs::install_autofs_requirements(){

  case "${::lsbdistcodename}" {
    "buster": {
      package {
        'autofs':
          ensure => installed;
      }
    }
    "bullseye", "bookworm" : {
      env::common::g5kpackages {
        'autofs-g5k':
          # see bug 13638
          ensure => '5.1.2-4',
          packages => ['autofs'],
          release => $::lsbdistcodename;
      }
    }
    default : {
      fail "${::lsbdistcodename} not supported."
    }
  }

  service {
    'autofs':
      ensure => running,
      require => Package['autofs'];
  }
}
