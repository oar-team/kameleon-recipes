# This file contains the 'base' class used to configure a basic environment to be executed in grid'5000.

class env::base ( $parent_parameters = {} ){

  $base_parameters = {
    misc_keep_tmp => true,
    ganglia_enable => false
  }

  $parameters = merge ( $base_parameters, $parent_parameters )
  # Include min class
  class {
    'env::min':
      parent_parameters => $parameters;
  }

  class { 'env::base::do_not_clean_tmp':
     keep_tmp => $parameters['misc_keep_tmp'];
  }

  # Include kexec-tools
  class { 'env::base::configure_kexec': }
  # SSH modification
  class { 'env::base::increase_ssh_maxstartups': }
  # Specific tuning
  class { 'env::base::tuning': }
  # Cpufreq
  class { 'env::base::enable_cpufreq_with_performance_governor': }
  # Ganglia
  class {
    'env::base::install_and_disable_ganglia':
      enable => $parameters['ganglia_enable']
  }
  # disable cstates
  class { 'env::base::disable_cstate': }
  # User packages
  class { 'env::base::packages': }

  # TODO Should be dropped from base
  #class { 'env::base::sshfs': }
  #class { 'env::base::infiniband': }
  #class { 'env::base::mx': }
  #class { 'env::base::openmpi': }
}
