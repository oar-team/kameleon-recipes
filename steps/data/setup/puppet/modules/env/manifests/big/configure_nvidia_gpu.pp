class env::big::configure_nvidia_gpu () {

  #packages = [ 'g++', 'gfortran', 'freeglut3-dev', 'libxmu-dev', 'libxi-dev' ]

  # Blacklist nvidia modules
  include 'env::big::configure_nvidia_gpu::modules'
  # Install nvidia drivers
  include 'env::big::configure_nvidia_gpu::drivers'
  # Install additional services (currently nvidia-smi, needed by cuda and prometheus)
  include 'env::big::configure_nvidia_gpu::services'
  # Install fabricmanager (needed by cluster with nvswitch technology)
  include 'env::big::configure_nvidia_gpu::fabricmanager'
  # Install cuda
  include 'env::big::configure_nvidia_gpu::cuda'
  # Install nvidia ganglia plugins
  include 'env::big::configure_nvidia_gpu::ganglia'
  # Install nvidia prometheus exporter
  include 'env::big::configure_nvidia_gpu::prometheus'

}
