# Description: classe to manage multiple OS version
#

class env::std::dell::params {

  $key = '1285491434D8786F'
  $packages = [
    'srvadmin-all',
  ]

  case $::lsbdistcodename {
    'jessie': {
      $src_location = "https://linux.dell.com/repo/community/debian/"
      $src_repos = 'openmanage'
    }

    'stretch': {
      $src_location = "https://linux.dell.com/repo/community/openmanage/910/${::lsbdistcodename}"
      $src_repos = 'main'

      env::common::g5kpackages {
        'ssl4dell':
          packages => 'libssl1.0.0';
      }

      Env::Common::G5kpackages['ssl4dell']->Package[$packages]
    }
  }
}
