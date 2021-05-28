class env::big::configure_amd_gpu () {

  apt::source {
    'repo.radeon.com':
      comment      => 'Repo for AMD ROCM packages',
      location     => 'https://repo.radeon.com/rocm/apt/debian/',
      release      => 'xenial',
      repos        => 'main',
      architecture => 'amd64',
      key          => {
        'id'     => '1A693C5C',
        'source' => 'https://repo.radeon.com/rocm/rocm.gpg.key',
      },
      include      => {
        'deb' => true,
        'src' => false
      },
      notify       => Exec['apt_update'],
  }

  package {
    [ 'rock-dkms', 'hip-base', 'rocminfo', 'rocm-smi-lib', 'hip-rocclr', 'rocm-device-libs' ]:
      ensure          => installed,
      install_options => ['--no-install-recommends'],
      require         => [Apt::Source['repo.radeon.com'], Exec['apt_update']];
  }

  file_line {
    'rocm_etc_profile_path':
      path => '/etc/profile',
      line => 'export PATH=$PATH:/opt/rocm-4.2.0/bin';
  }

}
