class env::base::enable_userns (){

  file {
    '/etc/sysctl.d/00-userns.conf':
      ensure   => file,
      owner    => root,
      group    => root,
      mode     => '0644',
      source   => 'puppet:///modules/env/base/userns/sysctl-00-userns.conf';
  }
}
