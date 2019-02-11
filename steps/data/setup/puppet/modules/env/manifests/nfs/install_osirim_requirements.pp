class env::nfs::install_osirim_requirements () {

  package {
    'autofs':
      ensure   => installed;
  }

  service {
    'autofs':
      ensure   => running,
      require  => Package['autofs'];
  }

  file {
    '/srv/osirim':
      ensure   => directory,
      owner    => root,
      group    => root,
      mode     => '0755';
    '/etc/auto.master.d':
      ensure   => directory,
      owner    => root,
      group    => root,
      mode     => '0755';
    '/etc/auto.master.d/osirim.autofs':
      ensure   => file,
      owner    => root,
      group    => root,
      mode     => '0644',
      content  => '/srv/osirim /etc/auto.osirim --timeout=60',
      require  => File['/etc/auto.master.d'],
      notify   => Service['autofs'];
    '/etc/auto.osirim':
      ensure   => file,
      owner    => root,
      group    => root,
      mode     => '0644',
      content  => '* -fstype=nfs,rw,nfsvers=3,hard,intr,async,noatime,nodev,nosuid,auto,rsize=32768,wsize=32768 osirim.toulouse.grid5000.fr:/ifs/grid5000/data/home/&',
      require  => File['/srv/osirim'],
      notify   => Service['autofs'];
  }
}
