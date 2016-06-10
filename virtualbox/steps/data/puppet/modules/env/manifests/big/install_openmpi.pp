class env::big::install_openmpi () {

  $openmpi_packages = [ 'librdmacm1', 'libgfortran3', 'libnuma1', 'blcr-util', 'libibverbs1-dbg', 'libopenmpi1.6', 'openmpi-common', 'openmpi-bin', 'libopenmpi-dev', 'openmpi-checkpoint' ]

  package{
    'libibverbs-dev':
      ensure => installed;
    $openmpi_packages:
      ensure     => installed,
      require    => Package['libibverbs-dev']
  }

}

