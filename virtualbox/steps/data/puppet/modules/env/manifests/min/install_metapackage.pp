class env::min::install_metapackage ( $variant ) {

  include apt

  $g5k_meta_packages_version = '0.7.17'

  case $operatingsystem {
    'Debian','Ubuntu': {
      if "${::lsbdistcodename}" == "stretch" {
        $g5kmetapackages = "g5k-meta-packages-debian9-$variant"
        } else {
          $g5kmetapackages = "g5k-meta-packages-${::lsbdistcodename}-$variant"
        }
    }
    default: {
      err "${operatingsystem} not supported."
    }
  }

  apt::source { 'g5k-meta-packages':
    key      => {
      'id'      => '3C38BDEAA05D4A7BED7815E5B1F34F56797BF2D1',
      'content' => file('env/min/apt/grid5000-archive-key.asc')
    },
    comment  => 'Grid5000 repository for g5k-meta-packages',
    location => 'http://packages.grid5000.fr/deb/g5k-meta-packages/',
    release  => "/",
    repos    => '',
    include  => { 'deb' => true, 'src' => false }
  }

  package {
    $g5kmetapackages:
       ensure  => $g5k_meta_packages_version,
       require => Class['apt::update']
  }
}
