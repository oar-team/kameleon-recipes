class env::xen::configure_xen () {

  if "$operatingsystem" == "Debian" {
    case "${::lsbdistcodename}" {
      'jessie' : {
        $hypervisor = "/boot/xen-4.4-${env::deb_arch}.gz"
        file {
          '/etc/xen/xend-config.sxp':
            ensure   => file,
            owner    => root,
            group    => root,
            mode     => '0644',
            backup   => ".puppet-bak",
            source   => 'puppet:///modules/env/xen/xen/xend-config.sxp',
            require  => Package['xen-utils'];
         '/etc/xen-tools/xen-tools.conf':
            ensure   => file,
            owner    => root,
            group    => root,
            mode     => '0644',
            content  => template("env/xen/xen/xen-tools.jessie.erb"),
            require  => File['/etc/xen-tools/xen-tools.conf.puppet-bak'],
            before   => Exec['create_example_domU'];
        }
      }
      default : {

        case "${::lsbdistcodename}" {
          'stretch' : {
            $hypervisor = "/boot/xen-4.8-${env::deb_arch}.gz"
            $xen_packages = [ 'xen-utils', 'debootstrap', 'xen-tools', 'sysfsutils', "xen-linux-system-${env::deb_arch}" ]
            file {
              '/etc/xen/xend-config.sxp.puppet-bak':
                ensure   => file,
                owner    => root,
                group    => root,
                mode     => '0644',
                source   => '/etc/xen/xend-config.sxp',
                require  => Package['xen-utils'];
            }

            file_line {
              '/etc/xen/xend-config.sxp: enable network bridge':
                path     => '/etc/xen/xend-config.sxp',
                line     => '(network-script network-bridge)',
                match    => '^#\ \(network-script\ network-bridge\)',
                require  => [ Package['xen-utils'], File['/etc/xen/xend-config.sxp.puppet-bak'] ],
                before   => Exec['create_example_domU'];
            }
          }

          'buster' : {
            $hypervisor = "/boot/xen-4.11-${env::deb_arch}.gz"
            $xen_packages = [ 'xen-utils', 'debootstrap', 'xen-tools', 'sysfsutils', "xen-system-${env::deb_arch}" ]
          }
        }

        file_line {
          '/etc/xen-tools/xen-tools.conf: change dir':
            path     => '/etc/xen-tools/xen-tools.conf',
            line     => 'dir = /opt/xen',
            match    => '^ *dir *=',
            require  => File['/etc/xen-tools/xen-tools.conf.puppet-bak'],
            before   => Exec['create_example_domU'];
          '/etc/xen-tools/xen-tools.conf: change size':
            path     => '/etc/xen-tools/xen-tools.conf',
            line     => 'size = 600M',
            match    => '^ *size *=',
            require  => File['/etc/xen-tools/xen-tools.conf.puppet-bak'],
            before   => Exec['create_example_domU'];
          '/etc/xen-tools/xen-tools.conf: change memory':
            path     => '/etc/xen-tools/xen-tools.conf',
            line     => 'memory = 128M',
            match    => '^ *memory *=',
            require  => File['/etc/xen-tools/xen-tools.conf.puppet-bak'],
            before   => Exec['create_example_domU'];
          '/etc/xen-tools/xen-tools.conf: change swap':
            path     => '/etc/xen-tools/xen-tools.conf',
            line     => 'swap = 128M',
            match    => '^ *swap *=',
            require  => File['/etc/xen-tools/xen-tools.conf.puppet-bak'],
            before   => Exec['create_example_domU'];
          '/etc/xen-tools/xen-tools.conf: change distribution':
            path     => '/etc/xen-tools/xen-tools.conf',
            line     => "dist = ${::lsbdistcodename}",
            match    => '^ *dist *=',
            require  => File['/etc/xen-tools/xen-tools.conf.puppet-bak'],
            before   => Exec['create_example_domU'];
          '/etc/xen-tools/xen-tools.conf: change arch':
            path     => '/etc/xen-tools/xen-tools.conf',
            line     => "arch = ${env::deb_arch}",
            match    => '^ *arch *=',
            require  => File['/etc/xen-tools/xen-tools.conf.puppet-bak'],
            before   => Exec['create_example_domU'];
          '/etc/xen-tools/xen-tools.conf: change mirror':
            path     => '/etc/xen-tools/xen-tools.conf',
            line     => 'mirror = http://ftp.fr.debian.org/debian/',
            match    => '^ *mirror *=',
            require  => File['/etc/xen-tools/xen-tools.conf.puppet-bak'],
            before   => Exec['create_example_domU'];
          '/etc/xen-tools/xen-tools.conf: change vmlinuz in xen-tools.conf':
            path     => '/etc/xen-tools/xen-tools.conf',
            line     => 'kernel = /vmlinuz',
            match    => '^kernel = /boot/vmlinuz',
            require  => File['/etc/xen-tools/xen-tools.conf.puppet-bak'],
            before   => Exec['create_example_domU'];
          '/etc/xen-tools/xen-tools.conf: chnage initrd.img path in xen-tools.conf':
            path     => '/etc/xen-tools/xen-tools.conf',
            line     => 'initrd = /initrd.img',
            match    => '^initrd = /boot/initrd.img',
            require  => File['/etc/xen-tools/xen-tools.conf.puppet-bak'],
            before   => Exec['create_example_domU'];
        }
      }
    }
  }

  package {
    $xen_packages :
      ensure   => installed;
      #notify   => Exec['update-grub'];
  }
  file {
    '/hypervisor':  # Given in dsc file to kadeploy to configure /boot/grub/grub.cfg correctly.
      ensure   => link,
      target   => "$hypervisor";
    '/root/.ssh/id_rsa':
      ensure   => file,
      owner    => root,
      group    => root,
      mode     => '0600',
      source   => 'puppet:///modules/env/xen/xen/id_rsa';
    '/root/.ssh/id_rsa.pub':
      ensure   => file,
      owner    => root,
      group    => root,
      mode     => '0600',
      source   => 'puppet:///modules/env/xen/xen/id_rsa.pub';
    '/etc/xen-tools/skel/root':
      ensure   => directory,
      owner    => root,
      group    => root,
      mode     => '0700',
      require  => Package['xen-tools'];
    '/etc/xen-tools/skel/root/.ssh':
      ensure   => directory,
      owner    => root,
      group    => root,
      mode     => '0700',
      require  => File['/etc/xen-tools/skel/root'];
    '/etc/xen-tools/skel/root/.ssh/authorized_keys': # Line content defined below
      ensure   => file,
      owner    => root,
      group    => root,
      mode     => '0600',
      require  => File['/etc/xen-tools/skel/root/.ssh'];
    '/etc/xen-tools/xen-tools.conf.puppet-bak':
      ensure   => file,
      owner    => root,
      group    => root,
      mode     => '0644',
      source   => '/etc/xen-tools/xen-tools.conf',
      require  => Package['xen-tools'];
    '/usr/local/bin/random_mac':
      ensure   => file,
      owner    => root,
      group    => root,
      mode     => '0755',
      source   => 'puppet:///modules/env/xen/xen/random_mac';
    '/usr/sbin/xen-g5k':
      ensure   => file,
      owner    => root,
      group    => root,
      mode     => '0755',
      source   => 'puppet:///modules/env/xen/xen/xen-g5k';
    '/etc/systemd/system/xen-g5k.service':
      ensure   => file,
      owner    => root,
      group    => root,
      mode     => '0644',
      source   => 'puppet:///modules/env/xen/xen/xen-g5k.service',
      notify   => Exec['daemon-reload'];
    '/etc/systemd/system/multi-user.target.wants/xen-g5k.service':
      ensure   => link,
      target   => '/etc/systemd/system/xen-g5k.service',
      require  => File['/etc/systemd/system/xen-g5k.service'],
      notify   => Exec['daemon-reload'];
  }

  exec {
    'daemon-reload':
      command     => '/bin/systemctl daemon-reload',
      refreshonly => true;
  }

  if $env::target_g5k {
    file {
      '/etc/xen-tools/skel/etc':
        ensure   => directory,
        owner    => root,
        group    => root,
        mode     => '0644',
        require  => Package['xen-tools'];
      '/etc/xen-tools/skel/etc/apt':
        ensure   => directory,
        owner    => root,
        group    => root,
        mode     => '0644',
        require  => File['/etc/xen-tools/skel/etc'];
      '/etc/xen-tools/skel/etc/apt/apt.conf.d':
        ensure   => directory,
        owner    => root,
        group    => root,
        mode     => '0644',
        require  => File['/etc/xen-tools/skel/etc/apt'];
      '/etc/xen-tools/skel/etc/dhcp':
        ensure   => directory,
        owner    => root,
        group    => root,
        mode     => '0644',
        require  => File['/etc/xen-tools/skel/etc'];
      '/etc/xen-tools/skel/etc/dhcp/dhclient-exit-hooks.d':
        ensure   => directory,
        owner    => root,
        group    => root,
        mode     => '0644',
        require  => File['/etc/xen-tools/skel/etc/dhcp'];
      '/etc/xen-tools/skel/etc/dhcp/dhclient-exit-hooks.d/g5k-update-host-name':
        ensure   => file,
        owner    => root,
        group    => root,
        mode     => '0644',
        source   => 'puppet:///modules/env/min/network/g5k-update-host-name',
        require  => File['/etc/xen-tools/skel/etc/dhcp/dhclient-exit-hooks.d'];
    }
  }

  file_line {
    '/etc/xen-tools/skel/root/.ssh/authorized_keys dom0_key':
      line     => file('env/xen/xen/id_rsa.pub'),
      path     => '/etc/xen-tools/skel/root/.ssh/authorized_keys',
      require  => File['/etc/xen-tools/skel/root/.ssh/authorized_keys'];
  }


  exec {
    'create_example_domU':
      command  => '/usr/bin/xen-create-image --hostname=domU --role=udev --genpass=0 --password=grid5000 --dhcp --mac=$(random_mac) --bridge=br0 --size=1G --memory=512M',
      creates  => '/etc/xen/domU.cfg',
      timeout  => 1200,
      require => [
        Package['xen-tools', 'xen-utils'],
        File_line['/etc/xen-tools/skel/root/.ssh/authorized_keys dom0_key'],
        File['/etc/xen-tools/xen-tools.conf.puppet-bak', '/usr/local/bin/random_mac']
      ];
  }
}
