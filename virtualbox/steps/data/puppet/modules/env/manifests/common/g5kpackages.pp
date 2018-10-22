# This class provides a wrapper for apt::source to make it easier to install packages from packages.grid5000.fr
# the default value for the 'packages' parameter is the name of the resource. So, you can use, e.g:
#  env::common::g5kpackages {
#   'sudo-g5k':
#      ensure => $::env::common::software_versions::sudo_g5k;
#  }

define env::common::g5kpackages (
  Variant[Array, String] $packages = $name,
  String $ensure = installed
) {
  include apt

  apt::source { $name:
    key      => {
      'id'      => '3C38BDEAA05D4A7BED7815E5B1F34F56797BF2D1',
      'content' => file('env/min/apt/grid5000-archive-key.asc')
    },
    comment  => "Grid5000 repository for ${name}",
    location => "http://packages.grid5000.fr/deb/${name}/",
    release  => "/",
    repos    => '',
    include  => { 'deb' => true, 'src' => false }
  }

  package {
    $packages:
       ensure  => $ensure,
       require => Class['apt::update']
  }
}
