class env::base::configure_omnipath(){


  case "${::lsbdistcodename}" {
    'buster': {
      $opapackages = ['opa-address-resolution', 'opa-fastfabric', 'libopamgt0', 'libopasadb1',
                      'opa-basic-tools', 'firmware-misc-nonfree']

      $rdmapackages = ['qperf', 'libibverbs1', 'librdmacm1', 'libibmad5', 'libibumad3', 'ibverbs-providers',
                      'rdmacm-utils', 'rdmacm-utils', 'infiniband-diags', 'libfabric1', 'ibverbs-utils']

      ensure_packages([$opapackages, $rdmapackages], {
        ensure => present
      })

      # rdma-load-modules@opa.service would fail with opa_vnic (not available)
      # opa_vnic isn't required to make OPA working
      exec {
        'disable opa_vnic':
          command => "/bin/sed -i 's/opa_vnic/# opa_vnic/g' /etc/rdma/modules/opa.conf",
          require => Package[$rdmapackages]
      }

    }
    'stretch': {
      $opapackages = ['opa-address-resolution', 'hfi1-diagtools-sw',
                      'hfi1-firmware', 'hfi1-uefi', 'libhfi1',
                      'opa-fastfabric', 'opa-scripts', 'qperf' ]

      env::common::g5kpackages {
          'scibian9-opa10.7':
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
}
