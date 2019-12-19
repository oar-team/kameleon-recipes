# This file contains the 'min' class used to configure an environment with minimal modification to be executed in grid'5000.

class env::min ( $variant = "min", $parent_parameters = {} ) {

  $min_parameters = {
    misc_root_pwd => '$1$qzZwnZXQ$Ak1xs7Oma6HUHw/xDJ8q91',
  }
  $parameters = merge( $min_parameters, $parent_parameters )

  # Package manager
  case $operatingsystem {
    'Debian','Ubuntu': {
    }
    'Centos': {
      class { 'env::min::yum': }
    }
    default: {
      err "${operatingsystem} not suported."
    }
  }
  # Install cpu microcode
  if $env::deb_arch == 'amd64' {
    class { 'env::min::install_cpu_microcode': }
  }
  # ssh
  class { 'env::min::install_and_configure_ssh': }
  # setup
  class { 'env::min::install_and_configure_locales': }
  # motd
  class { 'env::min::generate_etc_motd': }
  # tgs-g5k
  class { 'env::min::install_tgz_g5k': }
  # install meta-packages
  class { 'env::min::install_metapackage': variant => $variant }
  # network configuration
  class { 'env::min::configure_network_and_install_drivers': }
  # root password
  class { 'env::min::set_root_password':
     root_pwd => $parameters['misc_root_pwd'];
  }
  # timezone
  class { 'env::min::set_timezone_to_europe_paris': }
  # keep tmp

  # kernel installation
  class { 'env::min::configure_kernel_and_blacklist_some_modules': }
  # Tagging to recognize images
  class { 'env::min::add_image_version_in_etc': }
}
