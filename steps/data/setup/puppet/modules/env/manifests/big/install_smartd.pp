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

  # bug 15290: since bookworm, smartmontools fails if there is nothing to monitor, with exit code 17.
  # only for debian12: "-q never" lets smartd continue to run, waiting to load a configuration file listing valid devices.
  # for debian13 with v7.4, "-q nodev0" should work like "nodev" with exit code 0.
  if $::lsbdistcodename == 'bookworm' {
    file_line { 'smartmontools_config':
      ensure  => present,
      require => Package['smartmontools'],
      path    => '/etc/default/smartmontools',
      line    => 'smartd_opts="--quit=never"',
    }
  }
}
