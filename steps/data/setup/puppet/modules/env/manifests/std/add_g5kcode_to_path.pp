class env::std::add_g5kcode_to_path {

  file {
    '/root/.ssh':
      ensure  => directory,
      owner   => root,
      group   => root,
      mode    => '0700';
  }

  file {
    '/etc/profile.d/g5kcode.sh':
      ensure  => present,
      owner => root,
      group => root,
      mode  => '0644',
      content => 'export PATH=$PATH:/grid5000/code/bin';
  }
}
