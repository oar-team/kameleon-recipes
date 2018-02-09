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

  if "$operatingsystem" == "Debian" {
    case "${::lsbdistcodename}" {
      'jessie' : {
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
            require  => [Apt::Source['linux.dell.com'], Exec['apt_update']]
        }

        service { 'dataeng':
          enable => 'true',
          require => Package['srvadmin-all', 'dtk-scripts']
        }

        # Fix bug 7324
        file { '/etc/omreg.cfg':
          ensure => 'link',
          target => '/opt/dell/srvadmin/etc/omreg.cfg',
          require => Package['srvadmin-all', 'dtk-scripts']
        }

        # Fix bug 8048
        file {
          '/etc/systemd/system/dataeng.service.d':
            ensure  => 'directory',
            require => Package['srvadmin-all', 'dtk-scripts'];
          '/etc/systemd/system/dataeng.service.d/stop.conf':
            ensure  => 'file',
            content => "[Service]\nExecStop=\n",
            require => Package['srvadmin-all', 'dtk-scripts'];
        }
      }
      'stretch' : {
        $packToInstall = [ 'srvadmin-base', 'srvadmin-omcommon', 'srvadmin-server-cli', 'srvadmin-server-snmp', 'srvadmin-storageservices', 'srvadmin-storageservices-cli', 'srvadmin-storageservices-snmp', 'srvadmin-idracadm8', 'srvadmin-idrac-ivmcli', 'srvadmin-idrac-snmp', 'srvadmin-idrac-vmcli', 'srvadmin-deng', 'srvadmin-deng-snmp' ]

        exec {
          "retrieve_libssl1.0.0_1.0.1t-1+deb8u6_amd64":
          command  => "/usr/bin/wget --no-check-certificate -q https://www.grid5000.fr/packages/debian/libssl1.0.0_1.0.1t-1+deb8u6_amd64.deb -O /tmp/libssl_amd64.deb",
          creates  => "/tmp/libssl_amd64.deb";
        }
        package {
          "libssl1.0.0_1.0.1t-1+deb8u6_amd64":
          ensure   => installed,
          provider => dpkg,
          source   => "/tmp/libssl_amd64.deb",
          require  => [ Exec["retrieve_libssl1.0.0_1.0.1t-1+deb8u6_amd64"] ];
        }

        apt::source { 'linux.dell.com':
          comment  => 'Dell repository for OpenManage Server Administrator tools',
          location => 'http://linux.dell.com/repo/community/openmanage/901/xenial',
          release  => 'xenial',
          repos    => 'main',
          pin      => '500',
          key      => {
            'id'     => '1285491434D8786F',
            'server' => 'pool.sks-keyservers.net',
          },
          include  => {
            'src' => false,
            'deb' => true,
          },
        } -> package { $packToInstall:
          ensure => installed,
        }

        service { 'dataeng':
          enable => 'true',
          require => Package['srvadmin-base']
        }

        # Fix bug 7324
        file { '/etc/omreg.cfg':
          ensure => 'link',
          target => '/opt/dell/srvadmin/etc/omreg.cfg',
          require => Package['srvadmin-base']
        }

        # Fix bug 8048 and 8975
        file {
          '/etc/systemd/system/dataeng.service.d':
            ensure  => 'directory',
            require => Package['srvadmin-base'];
          '/etc/systemd/system/dataeng.service.d/stop.conf':
            ensure  => 'file',
            content => "[Service]\nExecStop=\nKillMode=control-group\nKillSignal=9",
            require => Package['srvadmin-base'];
        }
      }
    }
  }
}

