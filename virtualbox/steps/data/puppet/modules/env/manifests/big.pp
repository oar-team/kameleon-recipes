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
  class { 'env::big::configure_nvidia_gpu': }
  if "${::lsbdistcodename}" == "jessie" {
    # xeon phi, only on jessie. currently no package compiled for stretch
    class {
      'env::big::install_xeon_phi_requirements':
        enable  => $parameters['mic_enable']
    }
  }
  #Allow sshfs
  class { 'env::big::configure_sshfs': }
  # Config OpenMPI
  class { 'env::big::install_openmpi': }
  # Ceph
  class { 'env::big::install_ceph': }
  # Snmp tools
  class { 'env::big::install_snmp_tools': }
  # beegfs install
  class { 'env::big::install_beegfs': }
  # remove RESUME device from initramfs
  class { 'env::big::configure_initramfs': }

}
