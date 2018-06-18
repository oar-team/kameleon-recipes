class env::base::configure_omnipath(){

  if "${::lsbdistcodename}" == "stretch" {

    $opapackages = ['opa-address-resolution', 'hfi1-diagtools-sw',
                    'hfi1-firmware', 'hfi1-uefi', 'libhfi1',
                    'opa-fastfabric', 'opa-scripts', 'qperf' ]

    apt::source { 'scibian9opa10.6':
      comment  => 'Scibian 9 repository for the OPA 10.6 aspect',
      location => 'http://scibian.org/repo/',
      release  => 'scibian9+opa10.6',
      repos    => 'main',
      pin      => '500',
      key      => {
        'id'      => 'CA75B2A80E1CF8E9',
        'content' => template('env/base/omnipath/scibian.key.erb'),
      },
      include  => {
        'src' => false,
        'deb' => true,
      },
    }
    
    package { $opapackages:
      ensure  => installed,
      require => [Apt::Source['scibian9opa10.6'], Exec['apt_update']]
    }
  }
}
