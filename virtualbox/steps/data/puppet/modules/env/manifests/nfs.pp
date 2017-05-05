# This file contains the 'nfs' class used to configure a basic environment with nfs support to be executed in grid'5000.

class env::nfs ( $parent_parameters = {} ){
  $nfs_parameters = {
    ntp_drift_file => false
  }
  $parameters = merge( $nfs_parameters, $parent_parameters )
  # Include base class
  class {
    'env::base':
      parent_parameters => $parameters
  }
  # Openiscsi (storage5k)
  class { 'env::nfs::configure_iscsi': }
  # ntp (required by nfs)
  class {
    'env::nfs::configure_ntp':
      drift_file => $parameters['ntp_drift_file']
  }
  # package (shells)
  class { 'env::nfs::packages': }
  # ldap
  class { 'env::nfs::configure_ldap': }
  # nfs
  class { 'env::nfs::install_nfs_requirements': }
  # storage5k required
  class { 'env::nfs::install_storage5k_requirements': }
  # osirim
  class { 'env::nfs::install_osirim_requirements': }
}
