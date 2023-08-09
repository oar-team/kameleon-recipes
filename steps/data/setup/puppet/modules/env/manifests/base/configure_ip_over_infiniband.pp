class env::base::configure_ip_over_infiniband (){

  case "${::lsbdistcodename}" {
    'buster': {
      # En suivant la doc https://wiki.debian.org/RDMA, vous n'avez pas besoin d'installer opensm sur les environnements
      # Il risque de rentrer en conflit avec d'autres instances d'OpenSM présent sur du matériel réseau, ou bien sur des clusters externes à Grid5000 (exemple : https://intranet.grid5000.fr/bugzilla/show_bug.cgi?id=10747)
      service {
        'openibd':
          provider => 'systemd',
          enable   => true,
          require  => [
            File['/etc/systemd/system/openibd.service']
          ];
      }

      file {
        '/etc/infiniband':
          ensure => directory,
          owner  => root,
          group  => root,
          mode   => '0644';
        '/etc/infiniband/openib.conf':
          ensure  => file,
          owner   => root,
          group   => root,
          mode    => '0644',
          source  => 'puppet:///modules/env/base/infiniband/openib.conf',
          require => File['/etc/infiniband'];
        '/etc/init.d/openibd':
          ensure  => file,
          owner   => root,
          group   => root,
          mode    => '0755',
          source  => 'puppet:///modules/env/base/infiniband/openibd';
        '/etc/systemd/system/openibd.service':
          ensure => file,
          owner  => root,
          group  => root,
          mode   => '0644',
          source => 'puppet:///modules/env/base/infiniband/openibd.service';
        '/lib/udev/rules.d/90-ib.rules':
          ensure => present,
          owner  => root,
          group  => root,
          mode   => '0644',
          source => 'puppet:///modules/env/base/infiniband/90-ib.rules';
      }
    }
    'bullseye', 'bookworm': {
      package {
        'rdma-core':
          ensure =>  installed;
      }
      # Empeche que ibacm.service soit en status failed (voir #13013)
      file {
        '/etc/systemd/system/ibacm.service.d/':
          ensure  => directory;
        '/etc/systemd/system/ibacm.service.d/override.conf':
          ensure  => present,
          content => "[Service]\nType=exec\nExecStart=\nExecStart=-/usr/sbin/ibacm --systemd",
          require => File['/etc/systemd/system/ibacm.service.d/'];
      }
    }
    default : {
      fail "${::lsbdistcodename} not supported."
    }
  }
}
