class env::big::install_openmpi () {

  if "${::lsbdistcodename}" == "stretch" {
    $openmpi_deps_packages = [ 'librdmacm1', 'libgfortran3', 'libnuma1', 'blcr-util', 'libibverbs1-dbg', 'libibverbs-dev', 'libpsm2-dev', 'libhfi1-dev', 'libopamgt-dev' ]
    $openmpi_packages = [ 'libopenmpi-dev', 'openmpi-bin' ]
    $openmpi_scibian_version = '2.0.2-2sci9+opa10.6u1'

    package{
      $openmpi_deps_packages:
        ensure     => installed,
        require => Class['apt::update']
    }

    package {
      $openmpi_packages:
        ensure     => $openmpi_scibian_version,
        require => Class['apt::update']
    }

  } else {
    $openmpi_packages = [ 'librdmacm1', 'libgfortran3', 'libnuma1', 'blcr-util', 'libibverbs1-dbg', 'libopenmpi1.6', 'openmpi-common', 'openmpi-bin', 'libopenmpi-dev', 'openmpi-checkpoint' ]

    package{
      'libibverbs-dev':
        ensure => installed;
      $openmpi_packages:
        ensure     => installed,
        require    => Package['libibverbs-dev']
    }
  }
}

