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
      changes => [
        'set /files/etc/ssh/sshd_config/HostKey[1] /etc/ssh/ssh_host_rsa_key',
        'set /files/etc/ssh/sshd_config/HostKey[2] /etc/ssh/ssh_host_ecdsa_key',
        'set /files/etc/ssh/sshd_config/HostKey[3] /etc/ssh/ssh_host_ed25519_key',
        'set /files/etc/ssh/sshd_config/UsePrivilegeSeparation no',
        'set /files/etc/ssh/sshd_config/PermitRootLogin without-password',
        'set /files/etc/ssh/sshd_config/PermitUserEnvironment yes',
        'set /files/etc/ssh/sshd_config/MaxStartups 500'
      ],
      require  => Package['ssh server'];
  }
  # Todo: check that key files are overwritten by postinstall

  Augeas['sshd_config_min'] ~> Service['ssh']

}

