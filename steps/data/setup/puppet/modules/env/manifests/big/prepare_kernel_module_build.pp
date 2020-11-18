class env::big::prepare_kernel_module_build {

  # Prepare everything needed to build a custom kernel module.
  # Installs kernel headers for the latest available kernel, which can be different
  # from the running kernel.

  package {
    ['module-assistant', 'dkms']:
      ensure    => installed;
  }

  exec {
    'prepare_kernel_module_build':
      command   => "/usr/bin/m-a prepare -i -l ${installed_kernelreleases[-1]}",
      user      => root,
      require   => Package['module-assistant'];
  }
}
