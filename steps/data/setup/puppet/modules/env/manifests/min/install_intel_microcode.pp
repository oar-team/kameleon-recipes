class env::min::install_intel_microcode {

  package {
    'intel-microcode':
      ensure => installed;
  }

  file {
    '/etc/default/intel-microcode':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '644',
      source  => 'puppet:///modules/env/min/intel_microcode/intel-microcode',
      require => Package['intel-microcode'];
  }

  exec {
    'update_initramfs':
      command => '/usr/sbin/update-initramfs -u',
      require => File['/etc/default/intel-microcode'],
      refreshonly => true;
  }
}
