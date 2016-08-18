class env::base::unlimited_memlock_for_infiniband (){

# *** Setting up unlimited memlock (necessary for infiniband)
#
# See: https://intranet.grid5000.fr/bugzilla/show_bug.cgi?id=7183
#

  file {
    '/etc/security/limits.conf':
      ensure   => file,
      owner    => root,
      group    => root,
      mode     => '0644',
      source   => 'puppet:///modules/env/base/tuning/limits.conf';
  }
}
