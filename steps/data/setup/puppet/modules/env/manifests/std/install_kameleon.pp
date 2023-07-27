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
          fail "${lsbdistcodename} not supported."
        }
      }
    }
    default: {
      fail "${operatingsystem} not supported."
    }
  }
}
