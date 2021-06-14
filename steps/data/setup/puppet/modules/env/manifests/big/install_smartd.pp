class env::big::install_smartd {

  package {
    'smartmontools':
      ensure => installed;
  }

  file {
    '/etc/systemd/system/smartd.service.d/':
      ensure  => directory,
      require => Package['smartmontools'];
    '/etc/systemd/system/smartd.service.d/override.conf':
      ensure  => present,
      content => "[Service]\nExecStartPre=mkdir -p /dev/discs",
      require => File['/etc/systemd/system/smartd.service.d/'];
  }

  file_line { 'smard.conf':
    ensure  => present,
    require => Package['smartmontools'],
    path    => '/etc/smartd.conf',
    line    => 'DEVICESCAN -d nvme -d scsi -d ata -d sat -n standby -m root -M exec /usr/share/smartmontools/smartd-runner',
    match   => '^DEVICESCAN .*';
  }

}
