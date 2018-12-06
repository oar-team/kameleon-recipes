class env::base::configure_omnipath(){

  if "${::lsbdistcodename}" == "stretch" {

    $opapackages = ['opa-address-resolution', 'hfi1-diagtools-sw',
                    'hfi1-firmware', 'hfi1-uefi', 'libhfi1',
                    'opa-fastfabric', 'opa-scripts', 'qperf' ]

    env::common::g5kpackages {
        'scibian9-opa10.6':
           packages => $opapackages;
    }

    # There's a bug in the renicing of ib_mad processes (see bug 9421), so we disable it.
    exec {
      'disable renicing':
        command => "/bin/sed -i 's/RENICE_IB_MAD=yes/RENICE_IB_MAD=no/' /etc/rdma/rdma.conf",
        require => Package['opa-scripts']
    }
  }
}
