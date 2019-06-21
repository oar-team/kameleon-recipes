# Description: classe to manage multiple OS version
#

class env::std::dell::params {

  $key = '1285491434D8786F'

  case $::lsbdistcodename {
    'jessie': {
      $src_location = "https://linux.dell.com/repo/community/debian/"
      $src_repos = 'openmanage'
      $packages = [
        'srvadmin-all',
      ]
    }

    'stretch': {
      $src_location = "https://linux.dell.com/repo/community/openmanage/910/stretch"
      $src_repos = 'main'
      $packages = [
        'srvadmin-all',
      ]

      env::common::g5kpackages {
        'ssl4dell':
          packages => 'libssl1.0.0';
      }

      Env::Common::G5kpackages['ssl4dell']->Package[$packages]
    }

    'buster': {
      $src_location = "https://linux.dell.com/repo/community/openmanage/910/stretch" # FIXME : mettre src_location sur buster quand ce sera supporté
      $src_repos = 'main'
      $packages = ['srvadmin-base', 'srvadmin-storageservices', 'srvadmin-webserver', 'srvadmin-server-snmp', 'srvadmin-server-cli',
                   'srvadmin-oslog', 'srvadmin-idrac-snmp', 'srvadmin-idrac-ivmcli', 'srvadmin-idrac-vmcli', 'srvadmin-idracadm8',
                   'srvadmin-rac-components', 'srvadmin-racdrsc', 'libxslt1.1', 'libncurses5']

      env::common::g5kpackages {
        'ssl4dell':
          packages => 'libssl1.0.0';
      }

      Env::Common::G5kpackages['ssl4dell']->Package[$packages]
    }
  }
}
