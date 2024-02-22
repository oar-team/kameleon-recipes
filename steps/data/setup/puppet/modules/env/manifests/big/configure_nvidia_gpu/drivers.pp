class env::big::configure_nvidia_gpu::drivers () {

  ### This class exists for GPU clusters that require a recent version of nvidia driver

  include env::big::prepare_kernel_module_build

  case "$env::deb_arch" {
    "amd64": {
      $libdir = '/usr/lib/x86_64-linux-gnu'
    }
    "ppc64el": {
      $libdir = '/usr/lib/powerpc64le-linux-gnu'
    }
  }

  $driver_source = "http://packages.grid5000.fr/other/nvidia/NVIDIA-Linux-${::env::common::software_versions::nvidia_driver_arch}-${::env::common::software_versions::nvidia_driver}.run"
  $nvidia_basename = 'NVIDIA-Linux'
  $nvidia_runfile = "$nvidia_basename.run"

  file{
    "/tmp/$nvidia_runfile":
      ensure  => file,
      require => Exec['retrieve_nvidia_drivers'];
  }
  exec{
    'retrieve_nvidia_drivers':
      command => "/usr/bin/wget -q $driver_source -O /tmp/$nvidia_runfile && chmod u+x /tmp/$nvidia_runfile",
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
      'cleanup_nvidia_extracted':
        command   => "/bin/rm -r /tmp/$nvidia_basename",
        user      => root,
        require   => Exec['install_nvidia_driver'];
    }
    $nvidia_installer = "$nvidia_basename/nvidia-installer"
  } else {
    $nvidia_installer = "$nvidia_runfile"
  }

  # not install nvidia_driver for ppc64el bookworm
  # see https://intranet.grid5000.fr/bugzilla/show_bug.cgi?id=15183
  unless ("$env::deb_arch" == 'ppc64el' and "$lsbdistcodename" == 'bookworm') {
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
        command   => "/bin/rm /tmp/$nvidia_runfile",
        user      => root,
        require   => Exec['install_nvidia_driver'];
    }
  }

  if ($::env::common::software_versions::nvidia_user_driver != undef) {

    # Install a different user-mode driver.
    # See https://docs.nvidia.com/deploy/cuda-compatibility/index.html#forward-compatible-upgrade
    # This allows to use an old kernel driver with a newer user-mode driver (and thus support newer CUDA)
    # It is based on the NVIDIA driver installer, but we only extract relevant files.
    $user_driver_source = "http://packages.grid5000.fr/other/nvidia/NVIDIA-Linux-${::env::common::software_versions::nvidia_driver_arch}-${::env::common::software_versions::nvidia_user_driver}.run"

    file{
      '/tmp/NVIDIA-Linux-user-driver.run':
        ensure    => file,
        require   => Exec['retrieve_nvidia_user_driver'];
    }
    exec{
      'retrieve_nvidia_user_driver':
        command   => "/usr/bin/wget -q $user_driver_source -O /tmp/NVIDIA-Linux-user-driver.run; chmod u+x /tmp/NVIDIA-Linux-user-driver.run",
        timeout   => 1200, # 20 min
        creates   => "/tmp/NVIDIA-Linux-user-driver.run";
      'extract_nvidia_user_driver':
        command   => "/tmp/NVIDIA-Linux-user-driver.run -x --target /tmp/NVIDIA-Linux-user-driver",
        timeout   => 600, # 10 min,
        require   => File['/tmp/NVIDIA-Linux-user-driver.run'];
      'cleanup_nvidia_user_driver':
        command   => "/bin/rm /tmp/NVIDIA-Linux-user-driver.run",
        require   => Exec['extract_nvidia_user_driver'];
    }
    file{
      # Copy libraries from the newer driver
      "${libdir}/libcuda.so.${::env::common::software_versions::nvidia_user_driver}":
        source    => "/tmp/NVIDIA-Linux-user-driver/libcuda.so.${::env::common::software_versions::nvidia_user_driver}",
        mode      => '0755',
        require   => Exec['extract_nvidia_user_driver'];
      "${libdir}/libnvidia-ptxjitcompiler.so.${::env::common::software_versions::nvidia_user_driver}":
        source    => "/tmp/NVIDIA-Linux-user-driver/libnvidia-ptxjitcompiler.so.${::env::common::software_versions::nvidia_user_driver}",
        mode      => '0755',
        require   => Exec['extract_nvidia_user_driver'];
      # Override symlinks so that they point to the newer driver
      "${libdir}/libcuda.so.1":
        ensure    => link,
        target    => "libcuda.so.${::env::common::software_versions::nvidia_user_driver}",
        replace   => true,
        require   => Exec['install_nvidia_driver'];
      "${libdir}/libnvidia-ptxjitcompiler.so.1":
        ensure    => link,
        target    => "libnvidia-ptxjitcompiler.so.${::env::common::software_versions::nvidia_user_driver}",
        replace   => true,
        require   => Exec['install_nvidia_driver'];
    } ->
    exec{
      'cleanup_nvidia_user_driver_files':
        command   => "/bin/rm -r /tmp/NVIDIA-Linux-user-driver",
    }
  }
}
