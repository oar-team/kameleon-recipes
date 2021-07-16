class env::big::configure_nvidia_gpu::drivers () {

  ### This class exists for GPU clusters that require a recent version of nvidia driver

  include env::big::prepare_kernel_module_build

  $driver_source = "http://packages.grid5000.fr/other/nvidia/NVIDIA-Linux-$::env::common::software_versions::nvidia_driver.run"
  $nvidia_basename = 'NVIDIA-Linux'
  $nvidia_runfile = "$nvidia_basename.run"

  exec{
    'retrieve_nvidia_drivers':
      command => "/usr/bin/wget -q $driver_source -O /tmp/$nvidia_runfile; chmod u+x /tmp/$nvidia_runfile",
      timeout => 1200, # 20 min
      creates => "/tmp/$nvidia_runfile";
  }

  if ("$env::deb_arch" == 'ppc64el') and ("$lsbdistcodename" == 'buster') {
    exec{
      'extract_nvidia_driver':
        command   => "/tmp/$nvidia_runfile -x --target /tmp/$nvidia_basename",
        user      => root,
        require   => [Exec['prepare_kernel_module_build'], File["/tmp/$nvidia_runfile"]];
      'patch_nvidia_driver':
        command   => "/usr/bin/sed -i 's/MODULE_LICENSE(\"NVIDIA\");/MODULE_LICENSE(\"GPL\");/' /tmp/$nvidia_basename/kernel/nvidia-modeset/nvidia-modeset-linux.c; /usr/bin/sed -i 's/MODULE_LICENSE(\"NVIDIA\");/MODULE_LICENSE(\"GPL\");/' /tmp/$nvidia_basename/kernel/nvidia/nv-frontend.c",
        user      => root,
        require   => Exec['extract_nvidia_driver'];
    }
    $nvidia_installer = "$nvidia_basename/nvidia-installer"
  } else {
    $nvidia_installer = "$nvidia_runfile"
  }

  exec{
    'install_nvidia_driver':
      command   => "/tmp/$nvidia_installer -qa --no-cc-version-check --ui=none --dkms -k ${installed_kernelreleases[-1]}",
      timeout   => 1200, # 20 min,
      user      => root,
      # The nvidia installer tries to load the nvidia-drm module at the end, but it fails because
      # the building machine has no GPU. Make sure that modprobe doesn't actually try to load the module.
      environment => ['MODPROBE_OPTIONS=--dry-run'],
      require   => [Exec['prepare_kernel_module_build'], File["/tmp/$nvidia_runfile"]];
    'cleanup_nvidia':
      command   => "/bin/rm -r /tmp/$nvidia_basename*",
      user      => root,
      require   => Exec['install_nvidia_driver'];
  }

  file{
    "/tmp/$nvidia_runfile":
      ensure  => file,
      require => Exec['retrieve_nvidia_drivers'];
  }
}
