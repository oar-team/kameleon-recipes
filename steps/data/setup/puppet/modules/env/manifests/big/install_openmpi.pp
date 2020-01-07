class env::big::install_openmpi () {

  case "${::lsbdistcodename}" {

    "jessie" : {
      $openmpi_packages = [ 'librdmacm1', 'libgfortran3', 'libnuma1', 'blcr-util', 'libibverbs1-dbg', 'libopenmpi1.6', 'openmpi-common', 'openmpi-bin', 'libopenmpi-dev', 'openmpi-checkpoint' ]

      package{
        'libibverbs-dev':
          ensure => installed;
        $openmpi_packages:
          ensure     => present,
          require    => Package['libibverbs-dev']
      }
    }

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

    "buster" : {
      $openmpi_packages = [ 'libopenmpi-dev', 'openmpi-bin' ]
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
  }
}
