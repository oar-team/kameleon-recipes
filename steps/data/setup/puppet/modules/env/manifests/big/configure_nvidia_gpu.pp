class env::big::configure_nvidia_gpu () {

  #packages = [ 'g++', 'gfortran', 'freeglut3-dev', 'libxmu-dev', 'libxi-dev' ]

  # Blacklist nvidia modules
  include 'env::big::configure_nvidia_gpu::modules'
  # Install nvidia drivers
  include 'env::big::configure_nvidia_gpu::drivers'
  # Install additional services (currently nvidia-smi, needed by cuda and prometheus)
  include 'env::big::configure_nvidia_gpu::services'
  # Install fabricmanager (needed by cluster with nvswitch technology)
  if ($::env::common::software_versions::nvidia_fabricmanager) {
    include 'env::big::configure_nvidia_gpu::fabricmanager_deb'
  } else {
    include 'env::big::configure_nvidia_gpu::fabricmanager'
  }
  # Install cuda
  include 'env::big::configure_nvidia_gpu::cuda'
  # Install nvidia prometheus exporter
  include 'env::big::configure_nvidia_gpu::prometheus'

}
