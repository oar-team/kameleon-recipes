class env::big::configure_initramfs () {

  if "${::lsbdistcodename}" == "stretch" {
    file {
      '/etc/initramfs-tools/conf.d/resume':
        ensure    => present,
        owner     => root,
        group     => root,
        mode      => '0644',
        content   => 'RESUME=none',
    }
  }

}
