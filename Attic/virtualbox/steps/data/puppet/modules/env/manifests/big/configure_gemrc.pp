class env::big::configure_gemrc () {

  file {
    '/etc/gemrc':
      ensure     => present,
      owner      => root,
      group      => root,
      mode       => '644',
      source     => 'puppet:///modules/env/big/gem/gemrc';
  }
}
