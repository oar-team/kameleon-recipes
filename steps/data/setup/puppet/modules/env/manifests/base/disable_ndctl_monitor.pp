class env::base::disable_ndctl_monitor {
  file {
    '/etc/systemd/system-preset/' :
      ensure  => directory,
      owner   => root,
      group   => root,
      mode    => '0644';
    '/etc/systemd/system-preset/10-ndctl.preset' :
      ensure  => file,
      owner   => root,
      group   => root,
      mode    => '0644',
      source  => "puppet:///modules/env/base/ndctl/ndctl.preset",
      require => File['/etc/systemd/system-preset/'];
  }
}
