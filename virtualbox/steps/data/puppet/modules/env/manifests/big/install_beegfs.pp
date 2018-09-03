class env::big::beegfs::params {
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

    package { # for manual inspection, mostly.
    'beegfs-utils':
        require => Apt::Source['beegfs'],
        ensure => installed;
    }

    file { "/etc/beegfs":
        ensure => directory,
        owner  => root,
        group  => root,
        mode   => '0755';
    }

    file {
        "/etc/modules-load.d/rdma_ucm.conf":
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

class env::big::install_beegfs inherits env::big::beegfs::params {
  if "${::lsbdistcodename}" == "stretch" {
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
        refreshonly => true
    }


    package { # client
    'beegfs-helperd':
        require => Apt::Source['beegfs'],
        ensure => installed;
    }

    package { # client
    'beegfs-client':
        require => Apt::Source['beegfs'],
        ensure => installed;
    }
  }
}
