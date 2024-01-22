class env::big::install_openmpi () {

  $openmpi_packages = [ 'libopenmpi-dev', 'openmpi-bin' ]
  $openmpi_opa_packages = [ 'libpsm2-dev', 'libopamgt-dev' ]

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
    "bullseye", "bookworm" : {
      # Debian11|12 disable many providers by default. We restore UCX and Fabric,
      # while keeping openib disabled to avoid useless warnings
      file { '/etc/openmpi/openmpi-mca-params.conf':
        content => "#Managed by Grid'5000 environments recipes\nbtl_base_warn_component_unused=0\nbtl = ^openib",
        require => Package['openmpi-bin'];
      }
    }
    default: {
      fail "${::lsbdistcodename} not supported."
    }
  }
}
