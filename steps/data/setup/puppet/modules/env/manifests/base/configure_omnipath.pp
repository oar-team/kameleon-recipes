class env::base::configure_omnipath(){

  # opapackages depends on 'firmware-misc-nonfree' which is now installed on configure_network_and_install_drivers.pp for debian-min. 
  $opapackages = ['opa-address-resolution', 'opa-fastfabric', 'libopamgt0']

  $rdmapackages = ['qperf', 'ibverbs-providers', 'rdmacm-utils', 'infiniband-diags', 'ibverbs-utils']

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

  case "${::lsbdistcodename}" {
    'bullseye', 'bookworm': {

      # libfabric packages : G5K rebuild with efa provider disabled
      # See Bug #13260
      env::common::g5kpackages {
        'libfabric1':
          ensure => $::env::common::software_versions::libfabric1,
          packages => ['libfabric1', 'libfabric-bin'],
          release => $::lsbdistcodename;
      }

      ensure_packages(['ucx-utils'], {
        ensure => present
      })

      file {
        # Fix PSM2, see #13470
        '/lib/udev/rules.d/60-rdma-persistent-naming.rules':
          ensure  => 'file',
          content => 'ACTION=="add", SUBSYSTEM=="infiniband", PROGRAM="rdma_rename %k NAME_KERNEL"',
          require => Package['rdma-core'];
      }
    }
    'buster': {
      # NOTHING
    }
    default : {
      fail "${::lsbdistcodename} not supported."
    }
  }
}
