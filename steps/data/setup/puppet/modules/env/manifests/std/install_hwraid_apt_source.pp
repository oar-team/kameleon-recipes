class env::std::install_hwraid_apt_source {

  include apt

  # FIXME remove when HWRAID bullseye repository
  if "${::lsbdistcodename}" == "bullseye" {
    apt::source { 'hwraid.le-vert.net':
      key      => {
        'id'      => '0073C11919A641464163F7116005210E23B3D3B4',
        'content' => template('env/std/hwraid/hwraid.le-vert.net.key.erb'),
      },
      comment  => 'Repo for megacli package',
      location => 'http://hwraid.le-vert.net/debian',
      release  => "buster",
      repos    => 'main',
        include  => {
          'deb' => true,
          'src' => false
        }
  }

  } else {
    apt::source { 'hwraid.le-vert.net':
      key      => {
        'id'      => '0073C11919A641464163F7116005210E23B3D3B4',
        'content' => template('env/std/hwraid/hwraid.le-vert.net.key.erb'),
      },
      comment  => 'Repo for megacli package',
      location => 'http://hwraid.le-vert.net/debian',
      release  => "${::lsbdistcodename}",
      repos    => 'main',
        include  => {
          'deb' => true,
          'src' => false
      }
    }
  }
}
