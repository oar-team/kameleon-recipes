class env::big::configure_postfix () {

  $g5k_sysemail = 'sysadmin@internal.grid5000.fr'

  package {
    'postfix':
      ensure  => installed,
      require => Exec['fix_resolv_conf', 'fix_hostname'],
      before  => Exec['newaliases', 'set_root_alias'];
  }

  exec {
    'fix_resolv_conf':
      command  => "/bin/sed 's/\\([^\\s]*\\)\\.\\(\\s\\|$\\)/\\1\\2/g' -i /etc/resolv.conf";
    'fix_hostname':
      command  => "/bin/sed 's/localhost//' -i /etc/hostname";
    # set root alias to local + internal mailbox
    'set_root_alias':
      command  => "if /usr/bin/grep -q ^root: /etc/aliases; then /bin/sed -i 's/^root:.*/root: root, ${g5k_sysemail}/' /etc/aliases; else /usr/bin/echo 'root: root, ${g5k_sysemail}' >> /etc/aliases; fi",
      provider => 'shell';
    # update aliases database
    'newaliases':
      command  => '/usr/bin/newaliases',
  }

  # Keep default main.cf configuration file
  # Note that some configs are set with postconf by g5k-postinstall
}
