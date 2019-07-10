class env::big::install_xeon_phi_requirements ($enable = false) {

  case $operatingsystem {
    'Debian','Ubuntu': {

      $installed_packages = [ 'mpss-micmgmt', 'mpss-miccheck', 'mpss-coi', 'mpss-mpm', 'mpss-miccheck-bin', 'glibc2.12.2pkg-libsettings0', 'glibc2.12.2pkg-libmicmgmt0', 'libscif0', 'mpss-daemon', 'mpss-boot-files', 'mpss-sdk-k1om', 'intel-composerxe-compat-k1om' ]

      env::common::g5kpackages {
        'mpss':
          packages => $installed_packages,
          require  => File['/usr/lib64'];
      }

      case "${::lsbdistcodename}" {
        "stretch", "buster" {
          file{ '/usr/lib64':
            ensure => directory;
          '/etc/systemd/system/mpss.service':
            mode => "644",
            require => Package[$installed_packages];
          }
        }
        "jessie" {
          file{ '/usr/lib64':
            ensure => link,
            target => '/usr/lib';
          '/etc/systemd/system/mpss.service':
            mode => "644",
            require => Package[$installed_packages];
          }
        }
      }
    }
    default: {
      err "${operatingsystem} not suported."
    }
  }

  exec {
    'retrieve_mpss-modules':
      command => "/usr/bin/wget -q http://packages.grid5000.fr/deb/mpss/mpss-modules-3.4.4.tar.bz2 -O /tmp/mpss-modules/mpss-modules.tar.bz2",
      creates => "/tmp/mpss-modules/mpss-modules.tar.bz2",
      require => File['/tmp/mpss-modules'];
    'extract_mpss-modules':
      command => "/bin/tar jxf mpss-modules.tar.bz2",
      cwd     => "/tmp/mpss-modules/",
      require => Exec['retrieve_mpss-modules'];
    'install_mpss-modules':
      environment => ["INSTALL_MOD_PATH=/lib/modules/$(/bin/uname -r)/extra", "MIC_CARD_ARCH=k1om"],
      command => "/usr/bin/make ; /usr/bin/make install ; /sbin/depmod -a",
      cwd     => "/tmp/mpss-modules/",
      require => [Exec['extract_mpss-modules'], Exec['prepare_kernel_module_build']]; #prepare_kernel_module_build is defined in big/nvidia/drivers.pp
  }


  augeas {
    'module_mic':
      context => "/files/etc/modules",
      changes => ["ins mic after #comment[last()]",],
      onlyif  => "match mic size == 0 ";
    'blacklist_mic_host':
      context   => "/files/etc/modprobe.d/blacklist.conf",
      tag       => "modules",
      changes   =>["set blacklist[last()+1] mic_host",],
      onlyif    =>"match blacklist[.='mic_host'] size == 0 ";
  }


  file {
    # only used for compilation
    '/tmp/mpss-modules':
      ensure  => directory,
      mode    => '0755',
      owner   => root,
      group   => root;
    '/etc/init.d/mpss':
      ensure  => file,
      mode    => '0755',
      owner   => root,
      group   => root,
      source  => "puppet:///modules/env/big/mic/mpss";
    '/etc/mpss':
      ensure  => directory,
      mode    => '0755',
      owner   => root,
      group   => root;
    '/var/mpss':
      ensure  => directory,
      mode    => '0755',
      owner   => root,
      group   => root;
   '/var/mpss/mic0':
      ensure  => directory,
      mode    => '0755',
      owner   => root,
      group   => root,
      require => File['/var/mpss'];
    '/var/mpss/mic0/etc/':
      ensure  => directory,
      mode    => '0755',
      owner   => root,
      group   => root,
      require => File['/var/mpss/mic0'];
    '/var/mpss/mic0.filelist':
      ensure  => file,
      mode    => '0655',
      owner   => root,
      group   => root,
      source  => "puppet:///modules/env/big/mic/mic0.filelist";
    '/var/mpss/mic0/etc/fstab':
      ensure  => file,
      mode    => '0655',
      owner   => root,
      group   => root,
      source  => "puppet:///modules/env/big/mic/fstab";
    '/sbin/lspci':
      ensure  => link,
      owner   => root,
      group   => root,
      target  => '/usr/bin/lspci';
    '/etc/udev/rules.d/85-mic.rules':
      ensure  => file,
      mode    => '0644',
      owner   => root,
      group   => root,
      source  => "puppet:///modules/env/big/mic/85-mic.rules";
  }

  

  service {
    'mpss':
      enable  => $enable,
      require => Package['mpss-daemon'];
  }
}
