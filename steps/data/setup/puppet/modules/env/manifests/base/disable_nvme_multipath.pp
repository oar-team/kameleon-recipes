# Disable multipath support in the NVMe driver.
#
# Multipath makes the device name unpredictable (e.g. nvme0n1 vs nvme1n1
# when there are two NVMe drives), see https://intranet.grid5000.fr/bugzilla/show_bug.cgi?id=12958
#
# Multipath also creates a fake device node (e.g. nvme0c65n1) that messes up with g5k-checks:
#
# https://intranet.grid5000.fr/bugzilla/show_bug.cgi?id=12962
# https://intranet.grid5000.fr/bugzilla/show_bug.cgi?id=12955

class env::base::disable_nvme_multipath {
  file {
    '/etc/modprobe.d/disable_nvme_multipath.conf' :
      ensure  => file,
      owner   => root,
      group   => root,
      mode    => '0644',
      content => "options nvme_core multipath=off\n",
      notify  => Exec['generate_initramfs'];
  }
}
