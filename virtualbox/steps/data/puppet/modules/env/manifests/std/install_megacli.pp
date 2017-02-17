class env::std::install_megacli {

  require env::std::install_hwraid_apt_source
  
  package {
    'megacli':
       ensure => installed,
  }
   
}
