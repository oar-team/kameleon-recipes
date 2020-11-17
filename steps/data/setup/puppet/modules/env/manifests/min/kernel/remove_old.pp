class env::min::kernel::remove_old {
  # Remove the current kernel if it's not the last one
  if $kernelrelease != $installed_kernelreleases[-1] {
    package { "linux-image-$kernelrelease":
      ensure => 'purged'
    }

    file {
      "/lib/modules/$kernelrelease":
       ensure => absent,
       force  => true;
      "/usr/lib/modules/$kernelrelease":
       ensure => absent,
       force  => true;
    }
  }
}
