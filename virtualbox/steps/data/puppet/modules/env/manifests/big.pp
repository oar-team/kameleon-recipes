# This file contains the 'big' class used to configure improved environment to be executed in grid'5000.

class env::big ( $parent_parameters = {} ){

  $big_parameters = {
    mic_enable => false
  }
  $parameters = merge( $big_parameters, $parent_parameters )

  # Include nfs class
  class {
    'env::nfs':
      parent_parameters => $parameters
  }
  # Users packages
  class { 'env::big::packages': }
  # gem
  if $env::target_g5k {
    class { 'env::big::configure_gemrc':
      stage  => 'g5k_adjustment';
    }
  }
  # mail
  class { 'env::big::configure_postfix': }
  # kvm
  class { 'env::big::configure_kvm': }
  # nvidia
  class { 'env::big::configure_nvidia_gpu': }
  # xeon phi
  class {
    'env::big::install_xeon_phi_requirements':
      enable  => $parameters['mic_enable']
  }
  #Allow sshfs
  class { 'env::big::configure_sshfs': }
  # Config OpenMPI
  class { 'env::big::install_openmpi': }
  # Ceph
  class { 'env::big::install_ceph': }
  # Snmp tools
  class { 'env::big::install_snmp_tools': }

}
