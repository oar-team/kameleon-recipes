class env::base::do_not_clean_tmp ($keep_tmp = false) {

  if $keep_tmp {
    # Don't delete /tmp on reboot
    file {
      '/etc/tmpfiles.d/tmp.conf':
        ensure => 'link',
        target => '/dev/null';
    }
  }

}
