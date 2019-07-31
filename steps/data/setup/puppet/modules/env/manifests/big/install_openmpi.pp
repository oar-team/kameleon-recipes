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
      $openmpi_deps_packages = [ 'libnuma1', 'libibverbs-dev', 'libpsm2-dev', 'libopamgt-dev' ]

      ensure_packages($openmpi_deps_packages, {
        ensure => present,
        require => Class['apt::update']
      })

      ensure_packages($openmpi_packages, {
        ensure => present,
        require => Class['apt::update']
      })
    }
  }
}
