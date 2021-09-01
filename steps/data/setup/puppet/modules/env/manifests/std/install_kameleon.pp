class env::std::install_kameleon {

  case $operatingsystem {
    'Debian': {
      case "${lsbdistcodename}" {
        'bullseye': {
          env::common::g5kpackages {
            'kameleon':
              release => "${lsbdistcodename}";
          }
        }
        'buster': {
          # Add python2 dependancy. See bug #13322
          package {
            'python-future':
              ensure => installed;
          }

          env::common::g5kpackages {
            'kameleon':
              release => "${lsbdistcodename}";
          }
        }
        default: {
          err "${lsbdistcodename} not supported."
        }
      }
    }
    default: {
      err "${operatingsystem} not supported."
    }
  }
}
