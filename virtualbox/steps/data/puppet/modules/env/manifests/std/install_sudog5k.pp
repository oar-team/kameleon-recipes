class env::std::install_sudog5k {

  case $operatingsystem {
    'Debian': {
      require env::commonpackages::rake
      require env::commonpackages::rubyrspec
      require env::commonpackages::rsyslog

      apt::source { 'sudo-g5k':
        key      => {
          'id'      => '3C38BDEAA05D4A7BED7815E5B1F34F56797BF2D1',
          'content' => file('env/min/apt/grid5000-archive-key.asc')
        },
        comment  => 'Grid5000 repository for sudo-g5k',
        location => 'http://packages.grid5000.fr/deb/sudo-g5k/',
        release  => "/",
        repos    => '',
        include  => { 'deb' => true, 'src' => false }
      }


      package { 'sudo-g5k':
        ensure  => '1.1',
        require => Class['apt::update']
      }
    }
    default: {
      err "${operatingsystem} not suported."
    }
  }

  file {
    '/etc/sudo-g5k/id_rsa_sudo-g5k':
      ensure  => file,
      owner   => root,
      group   => root,
      mode    => '0600',
      source  => 'puppet:///modules/env/std/sudo-g5k/id_rsa_sudo-g5k',
      require => Package['sudo-g5k'];
  }
}
