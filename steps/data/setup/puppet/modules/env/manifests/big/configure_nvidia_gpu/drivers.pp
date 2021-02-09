class env::big::configure_nvidia_gpu::drivers () {

  ### This class exists for GPU clusters that require a recent version of nvidia driver

  include env::big::prepare_kernel_module_build

  $driver_source = "http://packages.grid5000.fr/other/nvidia/NVIDIA-Linux-$::env::common::software_versions::nvidia_driver.run"

  exec{
    'retrieve_nvidia_drivers':
      command   => "/usr/bin/wget -q $driver_source -O /tmp/NVIDIA-Linux.run; chmod u+x /tmp/NVIDIA-Linux.run",
      timeout   => 1200, # 20 min
      creates   => "/tmp/NVIDIA-Linux.run";
    'install_nvidia_driver':
      command   => "/tmp/NVIDIA-Linux.run -qa --no-cc-version-check --ui=none --dkms -k ${installed_kernelreleases[-1]}",
      timeout   => 1200, # 20 min,
      user      => root,
      # The nvidia installer tries to load the nvidia-drm module at the end, but it fails because
      # the building machine has no GPU. Make sure that modprobe doesn't actually try to load the module.
      environment => ['MODPROBE_OPTIONS=--dry-run'],
      require   => [Exec['prepare_kernel_module_build'], File['/tmp/NVIDIA-Linux.run']];
    'cleanup_nvidia':
      command   => "/bin/rm /tmp/NVIDIA-Linux.run",
      user      => root,
      require   => Exec['install_nvidia_driver'];
  }

  file{
    '/tmp/NVIDIA-Linux.run':
      ensure    => file,
      require   => Exec['retrieve_nvidia_drivers'];
  }
}
