# This file contains the 'nfs' class used to configure a basic environment with nfs support to be executed in grid'5000.

class env::nfs ( $variant = "nfs", $parent_parameters = {} ){
  $nfs_parameters = {
    ntp_drift_file => false
  }
  $parameters = merge( $nfs_parameters, $parent_parameters )
  # Include base class
  class {
    'env::base':
      variant => $variant,
      parent_parameters => $parameters;
  }
  # Openiscsi (storage5k)
  class { 'env::nfs::configure_iscsi': }
  # ntp (required by nfs)
  class {
    'env::nfs::configure_ntp':
      drift_file => $parameters['ntp_drift_file']
  }
  # ldap
  class { 'env::nfs::configure_ldap': }
  # nfs
  class { 'env::nfs::install_nfs_requirements': }
  # autofs
  class { 'env::nfs::install_autofs_requirements': }
  # storage5k required
  class { 'env::nfs::install_storage5k_requirements': }
  # module spack
  class { 'env::nfs::install_module': }
  # Souce profile by shell
  class { 'env::nfs::source_profile_by_shell': }
}
