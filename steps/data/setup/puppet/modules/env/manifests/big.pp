# This file contains the 'big' class used to configure improved environment to be executed in grid'5000.
class env::big ( $variant = "big", $parent_parameters = {} ){

  $big_parameters = {
    mic_enable => false
  }
  $parameters = merge( $big_parameters, $parent_parameters )

  # Include nfs class
  class {
    'env::nfs':
      variant => $variant,
      parent_parameters => $parameters;
  }
  # mail
  class { 'env::big::configure_postfix': }
  # kvm
  class { 'env::big::configure_kvm': }
  # nvidia
  if $env::deb_arch == 'amd64' or $env::deb_arch == 'ppc64el' {
    class { 'env::big::configure_nvidia_gpu': }
  }
  # beegfs install
  if $env::deb_arch == 'amd64' {
    class { 'env::big::install_beegfs': }
  }
  #Allow sshfs
  class { 'env::big::configure_sshfs': }
  # Config OpenMPI
  class { 'env::big::install_openmpi': }
  # Snmp tools
  class { 'env::big::install_snmp_tools': }
  # remove RESUME device from initramfs
  class { 'env::big::configure_initramfs': }
  # Prometheus
  class { 'env::big::install_prometheus_exporters': }
  # g5k-jupyterlab
  class { 'env::big::install_g5k_jupyterlab': }

}
