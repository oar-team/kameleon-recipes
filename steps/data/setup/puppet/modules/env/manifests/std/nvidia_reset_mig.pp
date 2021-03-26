class env::std::nvidia_reset_mig () {

  file{
    '/usr/local/bin/nvidia-reset-mig':
      ensure    => present,
      owner     => root,
      group     => root,
      mode      => '0755',
      source    => 'puppet:///modules/env/std/nvidia_configure/nvidia-reset-mig';
    '/etc/systemd/system/nvidia-reset-mig.service':
      ensure    => present,
      owner     => root,
      group     => root,
      mode      => '0644',
      source    => 'puppet:///modules/env/std/nvidia_configure/nvidia-reset-mig.service';
    '/etc/systemd/system/multi-user.target.wants/nvidia-reset-mig.service':
      ensure => link,
      target => '/etc/systemd/system/nvidia-reset-mig.service';

  }
}
