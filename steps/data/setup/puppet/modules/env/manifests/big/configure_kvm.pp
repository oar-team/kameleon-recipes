class env::big::configure_kvm () {

  package {
    'uml-utilities':
      ensure    => installed;
  }

  file {
    '/etc/sudoers.d/kvm':
      ensure    => present,
      owner     => root,
      group     => root,
      mode      => '0440',
      source    => 'puppet:///modules/env/big/kvm/sudoers',
      require   => Package['sudo'];
    '/etc/udev/rules.d/60-qemu-system.rules':
      ensure    => present,
      owner     => root,
      group     => root,
      mode      => '0644',
      source    => 'puppet:///modules/env/big/kvm/60-qemu-system.rules';
    '/usr/local/bin/create_tap':
      ensure    => present,
      owner     => root,
      group     => root,
      mode      => '0755',
      source    => 'puppet:///modules/env/big/kvm/create_tap';
    '/usr/lib/qemu/qemu-bridge-helper':
      ensure    => present,
      owner     => root,
      group     => root,
      mode      => '4755',
      require   => Env::Common::G5kpackages['g5k-meta-packages'];
    '/etc/qemu':
      ensure    => directory,
      owner     => root,
      group     => root,
      mode      => '0755';
    '/etc/qemu/bridge.conf':
      ensure    => file,
      owner     => root,
      group     => root,
      mode      => '0644',
      content   => "allow br0",
      require   => File['/etc/qemu'];
    '/usr/local/bin/random_mac':
      ensure    => present,
      owner     => root,
      group     => root,
      mode      => '0755',
      source    => 'puppet:///modules/env/big/kvm/random_mac';
  }

  Exec{
    'disable uml-utilities service':
      command => "/usr/sbin/update-rc.d uml-utilities disable",
      require => Package['uml-utilities'];
  }

  package {
    'sudo':
      ensure   => installed;
  }

  file_line { 'kvm_etc_profile_createpath':
    path => '/etc/profile',
    line => 'mkdir -p /tmp/$USER-runtime-dir';
  }

  file_line { 'kvm_etc_profile_path':
     path => '/etc/profile',
     line => 'export XDG_RUNTIME_DIR=/tmp/$USER-runtime-dir',
     require => File_line['kvm_etc_profile_createpath'];
  }

  # Not sure this is required anymore. Try without, uncomment if needed
  # augeas {
  #   'set_XDG_RUNTIME_DIR':
  #     context   => "/files/etc/profile",
  #     tag       => "modules",
  #     changes   =>["set export[last()+1] XDG_RUNTIME_DIR=/tmp/$USER-runtime-dir",];
  # }
}
