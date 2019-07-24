class env::min::install_cpu_microcode {

  package {
    ['intel-microcode','amd64-microcode']:
      ensure => installed;
  }

  file {
    '/etc/default/intel-microcode':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '644',
      source  => 'puppet:///modules/env/min/cpu_microcode/intel-microcode',
      require => Package['intel-microcode'];
    '/etc/default/amd64-microcode':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '644',
      source  => 'puppet:///modules/env/min/cpu_microcode/amd64-microcode',
      require => Package['amd64-microcode'];
  }

  exec {
    'update_initramfs':
      command => '/usr/sbin/update-initramfs -u',
      require => File['/etc/default/intel-microcode','/etc/default/amd64-microcode'],
      refreshonly => true;
  }
}
