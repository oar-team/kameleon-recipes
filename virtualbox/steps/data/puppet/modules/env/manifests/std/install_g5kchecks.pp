class env::std::install_g5kchecks {

  include 'env::std::ipmitool' # ipmitool is required by g5k-checks
  include 'env::std::dell'     # dell tools are required by g5k-checks

  case $operatingsystem {

    'Debian','Ubuntu': {

      require env::commonpackages::rake
      require env::commonpackages::rubyrspec

      if "${::lsbdistcodename}" != "jessie" {
        apt::source { 'g5k-checks':
          key      => {
            'id'      => '3C38BDEAA05D4A7BED7815E5B1F34F56797BF2D1',
            'content' => file('env/min/apt/grid5000-archive-key.asc')
          },
          comment  => 'Grid5000 repository for g5k-checks',
          location => 'http://packages.grid5000.fr/deb/g5k-checks/',
          release  => "/",
          repos    => '',
          include  => { 'deb' => true, 'src' => false }
        }

        package {
          "g5k-checks":
            ensure   => '0.8.5',
            require  =>  Class['apt::update'];
        }

        file {
          '/etc/g5k-checks.conf':
            ensure   => present,
            owner    => root,
            group    => root,
            mode     => '0644',
            source   => "puppet:///modules/env/std/g5kchecks/g5k-checks.conf",
            require  => Package["g5k-checks"];
        }
      }
    }
    default: {
      err "${operatingsystem} not supported."
    }
  }
}
