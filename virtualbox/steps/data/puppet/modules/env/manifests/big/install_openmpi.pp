class env::big::install_openmpi () {

  if "${::lsbdistcodename}" == "stretch" {
    $openmpi_packages = [ 'librdmacm1', 'libgfortran3', 'libnuma1', 'blcr-util', 'libibverbs1-dbg', 'libopenmpi2', 'openmpi-common', 'openmpi-bin', 'libopenmpi-dev' ]
  } else {
    $openmpi_packages = [ 'librdmacm1', 'libgfortran3', 'libnuma1', 'blcr-util', 'libibverbs1-dbg', 'libopenmpi1.6', 'openmpi-common', 'openmpi-bin', 'libopenmpi-dev', 'openmpi-checkpoint' ]
  }

  package{
    'libibverbs-dev':
      ensure => installed;
    $openmpi_packages:
      ensure     => installed,
      require    => Package['libibverbs-dev']
  }

}

