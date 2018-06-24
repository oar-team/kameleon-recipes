class env::base::configure_omnipath(){

  if "${::lsbdistcodename}" == "stretch" {

    $opapackages = ['opa-address-resolution', 'hfi1-diagtools-sw',
                    'hfi1-firmware', 'hfi1-uefi', 'libhfi1',
                    'opa-fastfabric', 'opa-scripts', 'qperf' ]

    # This repository is a local copy of scibian packages
    file {
      '/etc/apt/sources.list.d/scibian9-opa10.6.list':
        ensure  => file,
        owner   => root,
        group   => root,
        mode    => '0644',
        content => "deb [trusted=yes] http://apt.grid5000.fr/scibian9-opa10.6 /\ndeb [trusted=yes] http://apt.grid5000.fr/scibian9-opa10.6 /",
    } ~>
    exec {
      'apt_update_scibian':
        command     => '/usr/bin/apt-get update',
        refreshonly => true
    }
    
    package { $opapackages:
      ensure  => installed,
      require => [File['/etc/apt/sources.list.d/scibian9-opa10.6.list'], Exec['apt_update_scibian']]
    }

    # There's a bug in the renicing of ib_mad processes (see bug 9421), so we disable it.
    exec {
      'disable renicing':
        command => "/bin/sed -i 's/RENICE_IB_MAD=yes/RENICE_IB_MAD=no/' /etc/rdma/rdma.conf",
        require => Package['opa-scripts']
    }
  }
}
