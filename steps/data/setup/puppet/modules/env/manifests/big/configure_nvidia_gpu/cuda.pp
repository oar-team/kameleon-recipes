class env::big::configure_nvidia_gpu::cuda () {

  # May be changed to a link inside g5k if required
  $driver_source = 'http://packages.grid5000.fr/other/cuda/cuda_9.0.176_384.81_linux-run'
  case "${::lsbdistcodename}" {
    "buster" : {
      $opengl_packages = ['ocl-icd-libopencl1', 'opencl-headers']
      $install_opt = "--override" # gcc 8.3 is installed by buster and cuda 9 wants gcc 4.9 (https://docs.nvidia.com/cuda/archive/9.0/cuda-installation-guide-linux/index.html#system-requirements)
    }
    "stretch" : {
      $opengl_packages = ['ocl-icd-libopencl1', 'opencl-headers']
      $install_opt = ""
    }
    "jessie" : {
      $opengl_packages = ['ocl-icd-libopencl1', 'opencl-headers', 'amd-opencl-icd']
      $install_opt = ""
    }
  }

  exec{
    'retrieve_nvidia_cuda':
      command   => "/usr/bin/wget -q $driver_source -O /tmp/NVIDIA-Linux_cuda.run && chmod u+x /tmp/NVIDIA-Linux_cuda.run",
      timeout   => 1200, # 20 min
      creates   => "/tmp/NVIDIA-Linux_cuda.run";
    'install_nvidia_cuda':
      command   => "/tmp/NVIDIA-Linux_cuda.run --silent --toolkit --samples ${install_opt} && /bin/rm /tmp/NVIDIA-Linux_cuda.run",
      timeout   => 2400, # 20 min
      user      => root,
      require   =>  File['/tmp/NVIDIA-Linux_cuda.run'];
    'update_ld_conf':
      command   => "/sbin/ldconfig",
      user      => root,
      refreshonly => true;
  }
  case "${::lsbdistcodename}" {
    "stretch", "buster" : {
      file{
        '/tmp/NVIDIA-Linux_cuda.run':
          ensure    => file,
          require   => Exec['retrieve_nvidia_cuda'];
        '/usr/local/cuda/lib64/libcuda.so':
          ensure    => 'link',
          target    => '/usr/lib/x86_64-linux-gnu/libcuda.so',
          require   => Exec['install_nvidia_cuda'],
          notify    => Exec['update_ld_conf'];
        '/etc/ld.so.conf.d/cuda.conf':
          ensure    => file,
          owner     => root,
          group     => root,
          mode      => '0644',
          source    => 'puppet:///modules/env/big/nvidia/cuda-9.0.conf',
          notify    => Exec['update_ld_conf'];
        '/etc/systemd/system/nvidia-persistenced.service':
          ensure    => file,
          owner     => root,
          group     => root,
          mode      => '0644',
          source    => 'puppet:///modules/env/big/nvidia/nvidia-persistenced-9.0.service';
      }
    }
    "jessie" : {
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
    }
  }

  # Sounds dirty as fuck, but Augeas does not manage /etc/profile which is a bash file, and not a real configuration file (or I'm really bad with Augeas).
  file_line {
    'cuda_etc_profile_path':
      path => '/etc/profile',
      line => 'export PATH=$PATH:/usr/local/cuda/bin';
  }

  package{
    $opengl_packages:
      ensure    => installed;
  }
}
