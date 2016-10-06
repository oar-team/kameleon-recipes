# Install OpenManage Server Administrator tools (OMSA)
#
# Those tools are used by g5k-checks
#
# See also:
# * Bug #7218
# * https://www.grid5000.fr/mediawiki/index.php/TechTeam:BIOS_Configuration

include env::std::dell

class env::std::dell {

  include apt

  apt::source { 'linux.dell.com':
    comment  => 'Dell repository for OpenManage Server Administrator tools',
    location => 'http://linux.dell.com/repo/community/debian',
    release  => 'wheezy',
    repos    => 'openmanage',
    key      => {
      'id'     => '42550ABD1E80D7C1BC0BAD851285491434D8786F',
      'server' => 'pool.sks-keyservers.net',
    },
    include  => {
      'deb' => true,
      'src' => false
    }
  }
    
  package {
    ['srvadmin-all', 'dtk-scripts']:
      ensure   => 'installed',
      require  => Apt::Source['linux.dell.com']
  }
  
  service { 'dataeng':
    enable => 'true',
    require => Package['srvadmin-all', 'dtk-scripts']
  }
  
  # Fix bug 7324
  file { '/etc/omreg.cfg'
    ensure => 'link',
    target => '/opt/dell/srvadmin/etc/omreg.cfg',
    require => Package['srvadmin-all', 'dtk-scripts']
  }
}
