class env::base::configure_omnipath(){

  case "${::lsbdistcodename}" {
    'bullseye': {
      $opapackages = ['opa-address-resolution', 'opa-fastfabric', 'libopamgt0', 'libopasadb1',
                      'opa-basic-tools', 'firmware-misc-nonfree']

      # Note: G5K libfabric1 packages installed in install_openmpi.pp
      $rdmapackages = ['qperf', 'libibverbs1', 'librdmacm1', 'libibmad5', 'libibumad3', 'ibverbs-providers',
                      'rdmacm-utils', 'infiniband-diags', 'ibverbs-utils']

      if $env::deb_arch == 'amd64' {
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
      } else {
        # opapackages are only available on amd64
        ensure_packages($rdmapackages, {
          ensure => present
        })
      }
      file {
        # Fix PSM2, see #13470
        '/lib/udev/rules.d/60-rdma-persistent-naming.rules':
          ensure  => 'file',
          content => 'ACTION=="add", SUBSYSTEM=="infiniband", PROGRAM="rdma_rename %k NAME_KERNEL"',
          require => Package['rdma-core'];
      }
    }
    'buster': {
      $opapackages = ['opa-address-resolution', 'opa-fastfabric', 'libopamgt0', 'libopasadb1',
                      'opa-basic-tools', 'firmware-misc-nonfree']

      $rdmapackages = ['qperf', 'libibverbs1', 'librdmacm1', 'libibmad5', 'libibumad3', 'ibverbs-providers',
                      'rdmacm-utils', 'infiniband-diags', 'libfabric1', 'ibverbs-utils']

      if $env::deb_arch == 'amd64' {
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
      } else {
        # opapackages and libfabric1 are only available on amd64
        ensure_packages([$rdmapackages - ['libfabric1']], {
          ensure => present
        })
      }
    }
  }
}
