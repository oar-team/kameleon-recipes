class env::std::install_g5ksubnets {

  include env::common::software_versions

  env::common::g5kpackages {
    'g5k-subnets':
       ensure => $::env::common::software_versions::g5k_subnets;
  }
}
