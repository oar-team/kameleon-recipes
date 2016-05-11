class env::min::set_root_password ($root_pwd = '$1$qzZwnZXQ$Ak1xs7Oma6HUHw/xDJ8q91') {

  # Set root password
  user {
    'root':
      ensure   => 'present',
      password => $root_pwd;
  }

}
