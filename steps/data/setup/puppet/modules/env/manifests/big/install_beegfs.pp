class env::big::install_beegfs {

  case "${::lsbdistcodename}" {
    "stretch" : {

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

    "buster" : {

      include env::big::prepare_kernel_module_build

      apt::source { 'beegfs':
          location     => 'https://www.beegfs.com/release/beegfs_7_1/',
          release      => 'stretch',
          repos        => 'non-free',
          architecture => 'amd64',
          key          => {
              id       => '055D000F1A9A092763B1F0DD14E8E08064497785',
              source   => 'https://www.beegfs.io/release/beegfs_7/gpg/DEB-GPG-KEY-beegfs',
          },
      }
      -> package { # client
          [ 'beegfs-utils', 'beegfs-helperd', 'beegfs-client', 'libbeegfs-ib' ]:
          require => Class['apt::update'],
          ensure => installed;
      }
      -> service { [ 'beegfs-helperd', 'beegfs-client'] :
        provider => systemd,
        enable => false,
      }

      file { '/etc/beegfs/beegfs-client-autobuild.conf':
          content => "buildEnabled=true\nbuildArgs=-j8 BEEGFS_OPENTK_IBVERBS=1\n",
          require => Package['beegfs-client']
      }
      -> exec {
      '/etc/init.d/beegfs-client rebuild':
          timeout => 1200,
          refreshonly => true,
          require => Exec['prepare_kernel_module_build']
      }
    }

    'bullseye' : {
      # Official beegfs-client does not build for now (kernel 5.10)
      # cf. Bug #13077

      #include env::big::prepare_kernel_module_build

      #apt::source { 'beegfs_official':
      #    location     => 'https://www.beegfs.io/release/beegfs_7_1',
      #    release      => 'stretch', #FIXME : change release to bullseye when beegfs release it
      #    repos        => 'non-free',
      #    architecture => 'amd64',
      #    key          => {
      #        id       => '055D000F1A9A092763B1F0DD14E8E08064497785',
      #        source   => 'https://www.beegfs.io/release/beegfs_7_1/gpg/DEB-GPG-KEY-beegfs',
      #    },
      #}
      #-> package { # client
      #    [ 'beegfs-utils', 'beegfs-helperd', 'libbeegfs-ib' ]:
      #    require => Class['apt::update'],
      #    ensure => installed;
      #}
      #-> service {
      #  'beegfs-helperd' :
      #    provider => systemd,
      #    enable   => false,
      #}

      #env::common::g5kpackages {
      #  'beegfs':
      #    packages => 'beegfs-client',
      #    ensure   => '19:7.1.5-8-g5d4fbae18d';
      #}
      #-> service {
      #  'beegfs-client' :
      #    provider => systemd,
      #    enable   => false,
      #}


      #file { '/etc/beegfs/beegfs-client-autobuild.conf':
      #    content => "buildEnabled=true\nbuildArgs=-j8 BEEGFS_OPENTK_IBVERBS=1\n",
      #    require => Package['beegfs-client']
      #}
      #-> exec {
      #'/etc/init.d/beegfs-client rebuild':
      #    timeout => 1200,
      #    require => Exec['prepare_kernel_module_build']
      #}
    }
  }
}
