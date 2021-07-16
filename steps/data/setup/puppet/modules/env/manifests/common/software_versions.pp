# This file defines the software versions in use

class env::common::software_versions {
   $g5k_subnets                 = '1.4.2'
   $g5k_meta_packages           = '0.7.45'
   $tgz_g5k                     = '2.0.17'
   $g5k_checks                  = '0.11.1'
   $sudo_g5k                    = '1.11'
   $ganglia_monitor             = '3.6.0-7.1'
   $libguestfs_backport_arm64   = '1:1.40.2-7~bpog5k10+1'
   $libguestfs_backport_ppc64el = '1:1.40.2-7~bpog5k10+1'
   $lmod                        = '6.6-0.3g5k1'
   $g5k_jupyterlab              = '0.6'

  case "$env::deb_arch" {
    'amd64': {
      case $lsbdistcodename {
        'stretch', 'buster': {
          $nvidia_driver          = 'x86_64-450.119.04'
          $nvidia_cuda            = '10.1.243_418.87.00_linux'
          $datacenter_gpu_manager = '1:1.7.2'
          $dcgm_exporter          = '2.0.0-rc.11'
        }
        'bullseye': {
          $nvidia_driver          = 'x86_64-460.73.01'
          $nvidia_cuda            = '11.2.2_460.32.03_linux'
          $datacenter_gpu_manager = '1:2.1.4'
          $dcgm_exporter          = '2.3.0-1'
        }
      }
    }
    'ppc64el': {
      # Newer version of the driver (440.X, 450.X) are unstable and cause kernel panic.
      # See https://intranet.grid5000.fr/bugzilla/show_bug.cgi?id=12545
      $nvidia_cuda                = '10.1.243_418.87.00_linux_ppc64le'
      $nvidia_driver              = 'ppc64le-418.197.02'
      case $lsbdistcodename {
        'stretch', 'buster': {
          $datacenter_gpu_manager = '1:1.7.2'
          $dcgm_exporter          = '2.0.0-rc.11'
        }
        'bullseye': {
          $datacenter_gpu_manager = '1:2.0.15'
          $dcgm_exporter          = '2.3.0-1'
        }
      }
    }
  }
}
