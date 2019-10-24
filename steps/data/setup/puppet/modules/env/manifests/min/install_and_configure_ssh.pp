class env::min::install_and_configure_ssh {

  case $operatingsystem {
    'Debian','Ubuntu': {

      package {
        'ssh server':
          name => 'openssh-server',
          ensure => present;
      }

      service {
        'ssh':
          name   => 'ssh',
          ensure => running;
      }

    }

    'Centos': {

      package {
        'ssh server':
          name => 'sshd',
          ensure => present;
      }

      service {
        'ssh':
          name => 'sshd',
          ensure => running;
      }

    }
  }

  package {
    'ssh client':
      name => 'openssh-client',
      ensure => present;
  }

  augeas {
    'sshd_config_min':
      incl    => '/etc/ssh/sshd_config',
      lens    => 'Sshd.lns',
      changes => [
        'set /files/etc/ssh/sshd_config/PermitUserEnvironment yes',
        'set /files/etc/ssh/sshd_config/MaxStartups 500'
      ],
      require  => Package['ssh server'];
  }
  # Todo: check that key files are overwritten by postinstall

  Augeas['sshd_config_min'] ~> Service['ssh']

}

