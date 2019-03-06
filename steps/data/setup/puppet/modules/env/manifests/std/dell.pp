# Install OpenManage Server Administrator tools (OMSA)
#
# Those tools are used by g5k-checks
#
# See also:
# * Bug #7218
# * https://www.grid5000.fr/mediawiki/index.php/TechTeam:BIOS_Configuration

class { 'apt':
  update => {
    timeout => 1000
  }
}

class env::std::dell (
  String $key = $env::std::dell::params::key,
  String $src_location = $env::std::dell::params::src_location,
  String $src_repos = $env::std::dell::params::src_repos,
  Array $packages = $env::std::dell::params::packages,
) inherits env::std::dell::params {

  include apt

  apt::source {
    'dell':
      comment  => 'Dell repository for OpenManage Server Administrator tools',
      location => $src_location,
      release  => $::lsbdistcodename,
      repos    => $src_repos,
      key      => {
        'id'      => $key,
        'content' => template('env/std/dell/linux.dell.com.key.erb'),
      },
      include  => {
        'deb' => true,
        'src' => false
      },
      notify => Exec['apt_update']
  }

  package {
    $packages:
      ensure => present,
      require => [
        Apt::Source['dell'],
        Exec['apt_update']
      ]
  }

  service {
    'dataeng':
      enable => true,
      require => Package[$packages]
  }

  # Fix bug 7324
  # file { '/etc/omreg.cfg':
  #   ensure => 'link',
  #   target => '/opt/dell/srvadmin/etc/omreg.cfg',
  #   require => Package['srvadmin-base']
  # }

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
