class env::base::tcp_tuning_for_10gbe (){


# *** Setting up TCP buffers
#
# See: https://www.grid5000.fr/w/TCP_bandwidth_tuning
#

  file {
    '/etc/sysctl.d/00-grid5000.conf':
      ensure   => file,
      owner    => root,
      group    => root,
      mode     => '0644',
      source   => 'puppet:///modules/env/base/tuning/sysctl-00-grid5000.conf';
  }
}
