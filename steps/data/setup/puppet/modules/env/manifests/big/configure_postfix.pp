class env::big::configure_postfix () {

  $g5k_sysemail = 'sysadmin@internal.grid5000.fr'

  package {
    'postfix':
      ensure  => installed,
      require => Exec['fix_resolv_conf', 'fix_hostname'],
      before  => Exec['newaliases', 'set_root_alias'];
  }

  if ($::lsbdistcodename != 'bookworm') {
    exec {
      # This is a damn dirty patch due to a bug in the debian package for
      # postfix. In the package, the postinst script creates a
      # /etc/postfix/main.cfg with a myhostname attribute which is retrieved by
      # concatening the hostname found in /etc/hostname and domain extracted from
      # /etc/resolv.conf.  This domain MAY have a trailing dot (.grid5000.fr.)
      # Sadly, after this, newaliases is called on this /etc/postfix/main.cfg and
      # doesn't digest any trailing dot for attribute myhostname.
      'fix_resolv_conf':
        command  => "/bin/sed -e 's/\\.\\(\\s\\|$\\)/\\1/g' -i /etc/resolv.conf";
    }
  } else {
      # For bookworm, no need for the patch above since it is fixed.
      # See https://salsa.debian.org/postfix-team/postfix-dev/-/commit/a1d904dc162dfb810fc5b44b0f3efc45b07c12f8
      exec {
        'fix_resolv_conf':
          command  => "/bin/true";
      }
  }
  exec {
    'fix_hostname':
      command  => "/bin/sed -e 's/localhost//' -i /etc/hostname";
    # set root alias to local + internal mailbox
    'set_root_alias':
      command  => "if /usr/bin/grep -q ^root: /etc/aliases; then /bin/sed -i 's/^root:.*/root: root, ${g5k_sysemail}/' /etc/aliases; else /usr/bin/echo 'root: root, ${g5k_sysemail}' >> /etc/aliases; fi",
      provider => 'shell';
    # update aliases database
    'newaliases':
      command  => '/usr/bin/newaliases',
  }

  # Note that some configs are set with postconf by g5k-postinstall
}
