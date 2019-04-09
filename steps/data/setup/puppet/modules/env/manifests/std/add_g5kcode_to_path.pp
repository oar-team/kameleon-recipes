class env::std::add_g5kcode_to_path {

  file {
    '/root/.ssh':
      ensure  => directory,
      owner   => root,
      group   => root,
      mode    => '0700';
  }

  # Sounds dirty as fuck, but Augeas does not manage /etc/profile which is a bash file, and not a real configuration file (or I'm really bad with Augeas).
  file_line { 'g5kcode_etc_profile_path':
     path => '/etc/profile',
     line => 'export PATH=$PATH:/grid5000/code/bin';
  }
}
