class env::min::kernel::setup_links {
  # Ensure the kernel symlink will be installed in /
  file_line {
    '/etc/kernel-img.conf: update kernel symlink behavior to link in /':
      path     => '/etc/kernel-img.conf',
      line     => "link_in_boot = no",
      match    => '^link_in_boot =',
      before   => Exec['linux-update-symlinks'];
  }

  # Ensure symlinks to /boot are removed
  file {
    '/boot/vmlinuz':
      path     => '/boot/vmlinuz',
      ensure   => absent;
    '/boot/vmlinuz.old':
      path     => '/boot/vmlinuz.old',
      ensure   => absent;
    '/boot/initrd.img':
      path     => '/boot/initrd.img',
      ensure   => absent;
    '/boot/initrd.img.old':
      path     => '/boot/initrd.img.old',
      ensure   => absent;
  }

  # Setup symlink for initrd and vmlinuz
  exec {
    'linux-update-symlinks':
      command => "/usr/bin/linux-update-symlinks install ${kernelrelease} /boot/vmlinuz-${kernelrelease}";
  }

}
