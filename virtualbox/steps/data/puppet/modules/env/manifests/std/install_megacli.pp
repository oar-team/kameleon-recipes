class env::std::install_megacli {
  include apt

  apt::source { 'hwraid.le-vert.net':
    key      => {
      'id'      => '6005210E23B3D3B4',
      'server'  => 'pool.sks-keyservers.net',
    },
    comment  => 'Repo for megacli package',
    location => 'http://hwraid.le-vert.net/debian',
    release  => 'jessie',
    repos    => 'main',
     include  => {
      'deb' => true,
      'src' => false
    }
   }

   package {
     'megacli':
       ensure => installed,
       require => Apt::Source['hwraid.le-vert.net'];
   }
   
}
