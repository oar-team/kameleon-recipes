class env::std::disable_lvm_pvscan {

  # Disable LVM2 pvscan on std environment to avoid issues with disk reservation (see bug 9453)
  package {'lvm2':
    ensure => installed;
  }

  file {
    "/etc/lvm/lvm.conf":
      mode    => '0644',
      owner   => root,
      group   => root,
      source  => "puppet:///modules/env/std/lvm/lvm.conf",
      require => Package['lvm2'],
      notify  => Exec['generate_initramfs'];

  }
}

