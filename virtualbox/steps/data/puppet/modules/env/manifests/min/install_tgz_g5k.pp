class env::min::install_tgz_g5k {
  case $operatingsystem {
    'Debian','Ubuntu': {

      apt::source { 'tgz-g5k':
        key      => {
          'id'      => '3C38BDEAA05D4A7BED7815E5B1F34F56797BF2D1',
          'content' => file('env/min/apt/grid5000-archive-key.asc')
        },
        comment  => 'Grid5000 repository for tgz-g5k',
        location => 'http://packages.grid5000.fr/deb/tgz-g5k/',
        release  => "/",
        repos    => '',
        include  => { 'deb' => true, 'src' => false }
      }

      package { 'tgz-g5k':
        ensure  => '1.0.12',
        require => Class['apt::update']
      }
    }
    default: {
      err "${operatingsystem} not suported."
    }
  }
}

