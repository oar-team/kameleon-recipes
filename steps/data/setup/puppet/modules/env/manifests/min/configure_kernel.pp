class env::min::configure_kernel {

  # Install kernel : not required here. Kameleon set-up the kernel because it is required to have SSH access on the build VM (only access way for virtualbox backend)

  # Setup links: creates symlink /vmlinuz and /initrd pointing to real files in /boot
  include env::min::kernel::setup_links

  # initramfs regeneration declaration
  include env::min::kernel::initramfs

  # Remove old kernel if exist: it can happen that the running kernel (the installer's one) is not the most recent (installed after upgrade)
  class { 'env::min::kernel::remove_old':
    stage => last,
  }
}
