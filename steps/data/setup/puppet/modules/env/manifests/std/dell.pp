# Recipe from grid5000-puppet
# Don't forget to update both repositories when modifying something
#

class { 'apt':
  update => {
    timeout => 1000
  }
}

class env::std::dell (
  Array $packages_names = $env::std::dell::params::packages_names,
  String $service_name = $env::std::dell::params::service_name,
  String $service_status = $env::std::dell::params::service_status
) inherits env::std::dell::params {

  include apt

  $_key = '42550ABD1E80D7C1BC0BAD851285491434D8786F'

  case $::lsbdistcodename {
    'stretch': {
      $_location = "https://linux.dell.com/repo/community/openmanage/910/${::lsbdistcodename}"
      $_release = "${::lsbdistcodename}"
      $_repos = "main"
      $_packages_names = $packages_names
    }
    'buster': {
      # Pas de support officiel depuis buster
      $_location = "https://linux.dell.com/repo/community/openmanage/910/stretch"
      $_release = "stretch"
      $_repos = "main"
      $_packages_names = $packages_names
    }
    'bullseye': {
      # Pas de support officiel depuis buster
      #$_location = "https://linux.dell.com/repo/community/openmanage/911/stretch"
      #$_release = "stretch"
      # Test paquet récent pour Ubuntu 20.04
      $_location = "https://linux.dell.com/repo/community/openmanage/950/focal"
      $_release = "focal"
      $_repos = "main"
      $_packages_names = $packages_names - 'libssl1.0.0'
    }
  }

  apt::source {
    'dell':
      comment  => 'Dell repository for OpenManage Server Administrator tools',
      location => $_location,
      release  => $_release,
      repos    => $_repos,
      key      => {
        'id'      => $_key,
        'content' => template('env/std/dell/linux.dell.com.key.erb'),
      },
      include  => {
        'deb' => true,
        'src' => false
      },
      notify  => Exec['apt_update'];
  }

  package {
    $_packages_names:
      ensure  => present,
      require => [
        Apt::Source['dell'],
        Exec['apt_update'],
      ];
  }

  service {
    'dell OMSA':
      enable  => true,
      name    => $service_name,
      require => Package[$_packages_names];
  }

  if ($::lsbdistcodename == 'buster') or ($::lsbdistcodename == 'bullseye') {
    # Using enable => false doesn't seem to work, maybe because openipmi use systemd-sysv-generator
    exec {
      "disable openipmi service":
        command => "/lib/systemd/systemd-sysv-install disable openipmi",
        require => Package[$packages, 'ipmitool'];
    }
  }

  if ($::lsbdistcodename == 'buster') {
    # Fix bug 8048 and 8975
    file {
      '/etc/systemd/system/dataeng.service.d':
        ensure  => 'directory',
        require => Package[$packages];
      '/etc/systemd/system/dataeng.service.d/stop.conf':
        ensure  => 'file',
        content => "[Service]\nExecStop=\nKillMode=control-group\nKillSignal=9",
        require => Package[$packages];
    }
    File['/etc/systemd/system/dataeng.service.d']
    ->File['/etc/systemd/system/dataeng.service.d/stop.conf']
  }
}
