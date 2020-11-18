class env::big::configure_nvidia_gpu::drivers () {

  ### This class exists for gpuclus cluster, that require a recent version of nvidia driver

  case "$env::deb_arch" {
    "amd64": {
      $driver_source = 'http://packages.grid5000.fr/other/nvidia/NVIDIA-Linux-x86_64-450.80.02.run'
    }
    "ppc64el": {
      $driver_source = 'http://packages.grid5000.fr/other/nvidia/NVIDIA-Linux-ppc64le-450.80.02.run'
    }
    default: {
      err "${env::deb_arch} not supported"
    }
  }

  package {
    ['module-assistant', 'dkms']:
      ensure    => installed;
  }

  exec{
    'retrieve_nvidia_drivers':
      command   => "/usr/bin/wget -q $driver_source -O /tmp/NVIDIA-Linux.run; chmod u+x /tmp/NVIDIA-Linux.run",
      timeout   => 1200, # 20 min
      creates   => "/tmp/NVIDIA-Linux.run";
    'prepare_kernel_module_build':
      command   => "/usr/bin/m-a prepare -i",
      user      => root,
      require   => Package['module-assistant'];
    'install_nvidia_driver':
      command   => "/tmp/NVIDIA-Linux.run -qa --no-cc-version-check --ui=none --dkms -k ${installed_kernelreleases[-1]}; /bin/rm /tmp/NVIDIA-Linux.run",
      timeout   => 1200, # 20 min,
      user      => root,
      require   => [Exec['prepare_kernel_module_build'], File['/tmp/NVIDIA-Linux.run'], Package['dkms']];
  }
  file{
    '/tmp/NVIDIA-Linux.run':
      ensure    => file,
      require   => Exec['retrieve_nvidia_drivers'];
  }
}
