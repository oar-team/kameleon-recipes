class env::std::install_sudog5k {

  case $operatingsystem {
    'Debian': {
      require env::commonpackages::rake
      require env::commonpackages::rubyrspec
      require env::commonpackages::rsyslog

      env::common::g5kpackages {
        # See bug #13901
        'ruby-net-ssh':
          ensure => $::env::common::software_versions::ruby_net_ssh;
        'sudo-g5k':
          ensure => $::env::common::software_versions::sudo_g5k;
      }

    }
    default: {
      fail "${operatingsystem} not suported."
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
