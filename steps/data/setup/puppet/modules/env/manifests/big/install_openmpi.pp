class env::big::install_openmpi () {

  case "${::lsbdistcodename}" {

    "stretch" : {
      $openmpi_packages = [ 'libopenmpi-dev', 'openmpi-bin' ]
      $openmpi_deps_packages = [ 'librdmacm1', 'libgfortran3', 'libnuma1', 'blcr-util', 'libibverbs1-dbg', 'libibverbs-dev', 'libpsm2-dev', 'libhfi1-dev', 'libopamgt-dev' ]
      $openmpi_scibian_version = '2.0.2-2sci9+opa10.7u4'

      ensure_packages($openmpi_deps_packages, {
        ensure => present,
        require => Class['apt::update']
      })

      ensure_packages($openmpi_packages, {
        ensure => $openmpi_scibian_version,
        require => Class['apt::update']
      })
    }

    "buster", "bullseye" : {
      $openmpi_packages = [ 'libopenmpi-dev', 'openmpi-bin', 'ucx-utils', 'libfabric-bin' ]
      $openmpi_deps_packages = [ 'libnuma1', 'libibverbs-dev' ]
      $openmpi_opa_packages = [ 'libpsm2-dev', 'libopamgt-dev' ]

      ensure_packages($openmpi_deps_packages, {
        ensure => present,
        require => Class['apt::update']
      })

      if $env::deb_arch == 'amd64' {
        ensure_packages($openmpi_opa_packages, {
          ensure => present,
          require => Class['apt::update']
        })
      }

      ensure_packages($openmpi_packages, {
        ensure => present,
        require => Class['apt::update']
      })
    }
  }

  # Distribution specific fixes
  case "${::lsbdistcodename}" {

    "buster" : {
      # The 'verbs' OFI provider is broken in OpenMPI 3.1.3. We disable it.
      # See https://intranet.grid5000.fr/bugzilla/show_bug.cgi?id=10918
      # and https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=941996
      # https://github.com/open-mpi/ompi/issues/7035
      # OpenMPI 4.x is not affected, so this can be removed after buster.
      # This does not affect OpenMPI when loaded using 'module'
      file_line { 'disable_verbs_ofi_provider':
        path => '/etc/openmpi/openmpi-mca-params.conf',
        line => 'mtl_ofi_provider_exclude = shm,sockets,tcp,udp,rstream,verbs',
        require => Package['openmpi-bin'];
      }
    }

    "bullseye" : {
      # libfabric packages : G5K rebuild with efa provider disabled
      # cf Bug #13260
      env::common::g5kpackages {
        'libfabric1':
          packages => 'libfabric1';
      }
      # Debian11 disables many providers by default. We restore UCX and Fabric,
      # while keeping openib disabled to avoid useless warnings
      file { '/etc/openmpi/openmpi-mca-params.conf':
        content => "#Managed by Grid'5000 environement recipes\nbtl_base_warn_component_unused=0\nbtl = ^openib",
        require => Package['openmpi-bin'];
      }
    }
  }

}
