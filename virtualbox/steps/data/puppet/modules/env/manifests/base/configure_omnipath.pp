class env::base::configure_omnipath(){

  if "${::lsbdistcodename}" == "stretch" {

    $opapackages = ['opa-address-resolution', 'hfi1-diagtools-sw',
                    'hfi1-firmware', 'hfi1-uefi', 'libhfi1',
                    'opa-fastfabric', 'opa-scripts', 'qperf' ]

    # This repository is a local copy of scibian packages
    apt::source { 'scibian9-opa10.6':
      key      => {
        'id'      => '3C38BDEAA05D4A7BED7815E5B1F34F56797BF2D1',
        'content' => file('env/min/apt/grid5000-archive-key.asc')
      },
      comment  => 'Grid5000 repository for scibian9-opa10.6',
      location => 'http://packages.grid5000.fr/deb/scibian9-opa10.6/',
      release  => "/",
      repos    => '',
      include  => { 'deb' => true, 'src' => true }
    }

    package { $opapackages:
      ensure  => installed,
      require => Class['apt::update']
    }

    # There's a bug in the renicing of ib_mad processes (see bug 9421), so we disable it.
    exec {
      'disable renicing':
        command => "/bin/sed -i 's/RENICE_IB_MAD=yes/RENICE_IB_MAD=no/' /etc/rdma/rdma.conf",
        require => Package['opa-scripts']
    }
  }
}
