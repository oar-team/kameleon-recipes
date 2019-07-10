class env::big::install_beegfs {

  case "${::lsbdistcodename}" {
    "stretch", "buster" : {

      apt::source { 'beegfs':
          location     => 'https://www.beegfs.com/release/beegfs_7/',
          release      => 'deb9',
          repos        => 'non-free',
          architecture => 'amd64',
          key          => {
              id       => '055D000F1A9A092763B1F0DD14E8E08064497785',
              source   => 'https://www.beegfs.io/release/beegfs_7/gpg/DEB-GPG-KEY-beegfs',
          },
      }
      -> package { # client
          [ 'beegfs-utils', 'beegfs-helperd', 'beegfs-client', 'linux-headers-amd64', 'beegfs-opentk-lib' ]:
          require => Class['apt::update'], 
          ensure => installed;
      }
      -> service { [ 'beegfs-helperd', 'beegfs-client'] :
        provider => systemd,
        enable => false,
      }
      -> exec { "beegfs-setup-rdma":
        command => "/usr/sbin/beegfs-setup-rdma -i on"
      }

      file { '/etc/beegfs/beegfs-client-autobuild.conf':
          content => "buildEnabled=true\nbuildArgs=-j8 BEEGFS_OPENTK_IBVERBS=1\n",
          require => Package['beegfs-client']
      }
      -> exec {
      '/etc/init.d/beegfs-client rebuild':
          timeout => 1200,
          refreshonly => true
      }
    }
  }
}
