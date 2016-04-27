class env::big::misc {

  # Use bash as default shell
  file {
    '/bin/sh':
      ensure => 'link',
      target => '/bin/bash',
  }

}
