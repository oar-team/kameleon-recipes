# Limit CPU C-States Power Saving Modes to C0, C1 and C1E.

class env::base::configure_cstates {

  file {
    "/usr/local/sbin/force_cstates_c0-c1e.rb":
      mode    => '0744',
      owner   => root,
      group   => root,
      source  => "puppet:///modules/env/base/cstates/force_cstates_c0-c1e.rb";
    "/etc/systemd/system/cstates.service":
      mode    => '0644',
      owner   => root,
      group   => root,
      source  => "puppet:///modules/env/base/cstates/cstates.service";
    '/etc/systemd/system/multi-user.target.wants/cstates.service':
      ensure => link,
      target => '/etc/systemd/system/cstates.service';
  }

}
