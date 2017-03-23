class env::big::install_snmp_tools {

  package {
    'snmp':
      ensure => installed;
    'snmp-mibs-downloader':
      ensure => installed;
  }

  exec {
    'conf mibs':
      command => "/bin/sed -i 's/^mibs/#mibs/' /etc/snmp/snmp.conf",
      require => Package['snmp'];
    }
}
