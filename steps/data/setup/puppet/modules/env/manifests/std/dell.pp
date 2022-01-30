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
) inherits env::std::dell::params {

  include apt

  $_key = '42550ABD1E80D7C1BC0BAD851285491434D8786F'

  case $::lsbdistcodename {
    'stretch', 'buster': {
      # No official Debian support since buster
      # $_location = "https://linux.dell.com/repo/community/openmanage/910/stretch"
      $_location = "http://packages.grid5000.fr/deb/openmanage/910/stretch"
      $_release = "stretch"
      $_repos = "main"
      $_packages_names = $packages_names
      $service_status = 'service dataeng status'
    }
    'bullseye': {
      # Ubuntu 20.04 packages
      # $_location = "https://linux.dell.com/repo/community/openmanage/950/focal"
      $_location = "http://packages.grid5000.fr/deb/openmanage/950/focal"
      $_release = "focal"
      $_repos = "main"
      $_packages_names = $packages_names - 'libssl1.0.0'
      $service_status = 'systemctl status dsm_sa_datamgrd.service dsm_sa_eventmgrd.service'
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

  case $::lsbdistcodename  {
    # OMSA <= 9.1.0
    'stretch', 'buster': {
      service {
        'dataeng':
          enable  => true,
          require => Package[$_packages_names];
      }
    }
    # OMSA >= 9.3.0
    'bullseye': {
      service {
        'dsm_sa_datamgrd':
          enable  => true,
          require => Package[$_packages_names];
      }
      service {
        'dsm_sa_eventmgrd.service':
          enable  => true,
          require => Package[$_packages_names];
      }
    }
  }

  if ($::lsbdistcodename == 'buster') or ($::lsbdistcodename == 'bullseye') {
    # Using enable => false doesn't seem to work, maybe because openipmi use systemd-sysv-generator
    exec {
      'disable openipmi service':
        command => "/lib/systemd/systemd-sysv-install disable openipmi",
        require => Package[$packages, 'ipmitool'];
    }
  }

  if ($::lsbdistcodename == 'bullseye') {
    # Fix bug 12930
    exec {
      'disable NVMe devices support':
        command => "/bin/sed -i 's/^vil7=dsm_sm_psrvil/; vil7=dsm_sm_psrvil/' /opt/dell/srvadmin/etc/srvadmin-storage/stsvc.ini",
        require => Package[$_packages_names];
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
