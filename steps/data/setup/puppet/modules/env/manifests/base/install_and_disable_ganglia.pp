class env::base::install_and_disable_ganglia ($enable = false){

  include env::common::software_versions

  if "$operatingsystem" == 'Debian' {
    case "${::lsbdistcodename}" {
      'buster' : {
        env::common::g5kpackages {
          'ganglia-monitor':
            ensure  => $::env::common::software_versions::ganglia_monitor,
            release => "${::lsbdistcodename}";
        }

        file {
          '/etc/ganglia' :
            ensure  => directory,
            owner   => root,
            group   => root,
            mode    => '0644';
          '/etc/ganglia/gmond.conf' :
            ensure  => file,
            owner   => root,
            group   => root,
            mode    => '0644',
            source  => "puppet:///modules/env/base/ganglia/gmond.conf",
            require => File['/etc/ganglia'];
        }

        service {
          'ganglia-monitor':
            enable  => $enable,
            require => Package['ganglia-monitor'];
        }
      }
      default : {
        # No more ganglia since bullseye
      }
    }
  }
}
