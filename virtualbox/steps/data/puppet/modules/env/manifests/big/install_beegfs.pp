class env::big::install_beegfs {
  if "${::lsbdistcodename}" == "stretch" {

    package { 'apt-transport-https':
        ensure => installed,
    }

    apt::source { 'beegfs':
        location     => 'http://www.beegfs.com/release/beegfs_7/',
        release      => 'deb9',
        repos        => 'non-free',
        architecture => 'amd64',
        key          => {
            id       => '055D000F1A9A092763B1F0DD14E8E08064497785',
            source   => 'https://www.beegfs.io/release/beegfs_7/gpg/DEB-GPG-KEY-beegfs',
        },
        require => Package['apt-transport-https'],
    }
    ~> exec { "apt-get update beegfs": command => "/usr/bin/apt-get update" }

    package { # client
        ['beegfs-utils', 'beegfs-helperd', 'beegfs-client']:
        require => Apt::Source['beegfs'],
        ensure => installed;
    }

    package {
        ['linux-headers-amd64', 'beegfs-opentk-lib']:
        require => Apt::Source['beegfs'],
        ensure => installed;
    } ~>
    file { '/etc/beegfs/beegfs-client-autobuild.conf':
        content => "buildEnabled=true\nbuildArgs=-j8 BEEGFS_OPENTK_IBVERBS=1\n",
        require => Package['beegfs-client']
    }
    ~> exec {
    '/etc/init.d/beegfs-client rebuild':
        timeout => 1200,
        refreshonly => true
    }

    file { "/etc/beegfs":
        ensure => directory,
        owner  => root,
        group  => root,
        mode   => '0755';
    }

    file {
        "/etc/modules-load.d/beegfs.conf":
            require => Package['beegfs-utils'],
            ensure  => file,
            mode    => '0644',
            owner   => root,
            group   => root,
            content => "rdma_ucm\n",
    }
    ~> exec { "modprobe rdma_ucm": command => "/sbin/modprobe rdma_ucm" }
    ~> exec { "beegfs-setup-rdma": command => "/usr/sbin/beegfs-setup-rdma" }
  }

}
