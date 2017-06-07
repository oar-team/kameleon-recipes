class env::big::configure_nvidia_gpu::cuda () {

  # May be changed to a link inside g5k if required
  $driver_source = 'https://www.grid5000.fr/packages/debian/cuda_8.0.61_linux-run'
  $opengl_packages = ['ocl-icd-libopencl1', 'opencl-headers', 'amd-opencl-icd']

  exec{
    'retrieve_nvidia_cuda':
      command   => "/usr/bin/wget --no-check-certificate -q $driver_source -O /tmp/NVIDIA-Linux_cuda.run; chmod u+x /tmp/NVIDIA-Linux_cuda.run",
      timeout   => 1200, # 20 min
      creates   => "/tmp/NVIDIA-Linux_cuda.run";
    'install_nvidia_cuda':
      command   => "/tmp/NVIDIA-Linux_cuda.run --silent --toolkit --samples ; /bin/rm /tmp/NVIDIA-Linux_cuda.run",
      user      => root,
      require   =>  File['/tmp/NVIDIA-Linux_cuda.run'];
    'update_ld_conf':
      command   => "/sbin/ldconfig",
      user      => root,
      refreshonly => true;
  }
  file{
    '/tmp/NVIDIA-Linux_cuda.run':
      ensure    => file,
      require   => Exec['retrieve_nvidia_cuda'];
    '/etc/ld.so.conf.d/cuda.conf':
      ensure    => file,
      owner     => root,
      group     => root,
      mode      => '0644',
      source    => 'puppet:///modules/env/big/nvidia/cuda.conf',
      notify    => Exec['update_ld_conf'];
    '/usr/local/cuda/lib64/libcuda.so':
      ensure    => 'link',
      target    => '/usr/lib/libcuda.so';
  }

# Sounds dirty as fuck, but Augeas does not manage /etc/profile which is a bash file, and not a real configuration file (or I'm really bad with Augeas).
file_line {
  'cuda_etc_profile_path':
     path => '/etc/profile',
     line => 'export PATH=$PATH:/usr/local/cuda/bin';
  'ld_library_path':
     path => '/etc/profile',
     line => 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64';
  }

  package{
    $opengl_packages:
      ensure    => installed;
  }
}
