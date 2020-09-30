class env::base::install_ipmctl(){

  include env::common::software_versions

  # Force ipmctl version from our repo to fix issues with PMEM support
  # Bug 12277
  if $env::deb_arch == 'amd64' and "${::lsbdistcodename}" == 'buster' {

    env::common::g5kpackages {
      'ipmctl':
         packages => ['libipmctl4', 'ipmctl'],
         ensure => $::env::common::software_versions::ipmctl;
    }

  }
}
