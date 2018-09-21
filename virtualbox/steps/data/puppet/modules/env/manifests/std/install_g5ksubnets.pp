class env::std::install_g5ksubnets {

  apt::source { 'g5k-subnets':
    key      => {
      'id'      => '3C38BDEAA05D4A7BED7815E5B1F34F56797BF2D1',
      'content' => file('env/min/apt/grid5000-archive-key.asc')
    },
    comment  => 'Grid5000 repository for g5k-subnets',
    location => 'http://packages.grid5000.fr/deb/g5k-subnets/',
    release  => "/",
    repos    => '',
    include  => { 'deb' => true, 'src' => false }
  }

  package {
    'g5k-subnets':
      ensure   => '1.4.1',
      require  =>  Class['apt::update'];
  }
}
