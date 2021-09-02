class env::std::install_kameleon {

  case $operatingsystem {
    'Debian': {
      case "${lsbdistcodename}" {
        'buster', 'bullseye': {
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
