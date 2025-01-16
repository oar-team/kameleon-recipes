# This file defines the software versions in use

class env::common::software_versions {
  $g5k_subnets                 = '1.4.2'
  $g5k_meta_packages           = '0.7.52'
  $g5k_checks                  = '0.11.19'
  $sudo_g5k                    = '1.13'
  $ruby_net_ssh                = '1:6.1.0-2+deb11u1'
  $libguestfs_backport_arm64   = '1:1.40.2-7~bpog5k10+1'
  $libguestfs_backport_ppc64el = '1:1.40.2-7~bpog5k10+1'
  $g5k_jupyterlab              = '0.11'

  if "$env::deb_arch" == 'amd64' {
    case $lsbdistcodename {
      'bullseye' : {
        $singularity_package  = 'singularity-ce'
        $singularity_version  = '4.1.2-focal'
      }
      'bookworm' : {
        $singularity_package  = 'singularity-container'
        $singularity_version  = '4.1.5+ds3-1~fto12+1'
      }
    }
  }

  case "${env::deb_arch}" {
    'amd64': {
      $nvidia_driver_arch         = 'x86_64'
      case $lsbdistcodename {
        'buster': {
          $rocm_version           = '4.3.1'
          $nvidia_driver          = '460.91.03'
          $nvidia_cuda            = '10.1.243_418.87.00_linux'
          $datacenter_gpu_manager = '1:1.7.2'
          $dcgm_exporter          = '2.0.0-rc.11'
        }
        'bullseye': {
          $lmod                   = '8.6.19-1+g5k1.0.5'
          $rocm_version           = '4.5'
          $nvidia_driver          = '535.183.06'
          $nvidia_cuda            = '11.2.2_460.32.03_linux'
          $datacenter_gpu_manager = '1:3.3.3'
          $nvidia_fabricmanager   = '535_535.183.06-1'
          $dcgm_exporter          = '3.3.5-1'
          $libfabric1             = '1.11.0-2+g5k1'
        }
        'bookworm': {
          $lmod                   = '8.6.19-1+g5k1.0.5'
          $rocm_version           = '4.5'
          $nvidia_driver          = '550.54.14'
          $nvidia_cuda            = '12.2.2_535.104.05_linux'
          $datacenter_gpu_manager = '1:3.3.3'
          $nvidia_fabricmanager   = '550_550.54.14-1'
          $dcgm_exporter          = '3.3.5-1'
          $libfabric1             = '1.11.0-2+g5k1'
        }
        default : {
          fail "${::lsbdistcodename} not supported."
        }
      }
    }
    'ppc64el': {
      # We are stuck on driver 418 for ppc64.
      # Newer version of the driver (440.X, 450.X, 460.X) are unstable and cause kernel panic.
      # See https://intranet.grid5000.fr/bugzilla/show_bug.cgi?id=12545
      $nvidia_driver_arch         = 'ppc64le'
      case $lsbdistcodename {
        'buster': {
          $nvidia_driver          = '418.197.02'
          $nvidia_cuda            = '10.1.243_418.87.00_linux_ppc64le'
          $datacenter_gpu_manager = '1:1.7.2'
          $dcgm_exporter          = '2.0.0-rc.11'
        }
        'bullseye': {
          $lmod                   = '8.6.19-1+g5k1.0.5'
          $nvidia_driver          = '418.197.02'
          $nvidia_user_driver     = '460.91.03'
          $nvidia_cuda            = '11.2.2_460.32.03_linux_ppc64le'
          $datacenter_gpu_manager = '1:2.0.15'
          $dcgm_exporter          = '2.3.0-1'
          $libfabric1             = '1.11.0-2+g5k1'
        }
        'bookworm': {
          $lmod                   = '8.6.19-1+g5k1.0.5'
          $nvidia_driver          = '418.197.02'
          $nvidia_cuda            = '12.2.2_535.104.05_linux_ppc64le'
          $datacenter_gpu_manager = '1:2.0.15'
          $dcgm_exporter          = '2.3.0-1'
          $libfabric1             = '1.11.0-2+g5k1'
        }
        default : {
          fail "${::lsbdistcodename} not supported."
        }
      }
    }
  }
}
