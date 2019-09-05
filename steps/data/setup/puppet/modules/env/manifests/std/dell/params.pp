# Recipe from grid5000-puppet, keep synchronized!
#

class env::std::dell::params {

  $packages_names = [
    'srvadmin-base',
    "srvadmin-idracadm7",
    "srvadmin-idracadm8",
    'srvadmin-storageservices',
    'srvadmin-omcommon',
    'libncurses5',
    'libxslt1.1',
    'libssl1.0.0',
  ]
  $service_name = 'dataeng'
  $service_status = 'service dataeng status'
}
