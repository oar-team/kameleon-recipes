class env::big::configure_nvidia_gpu::cuda () {

  case "${::lsbdistcodename}" {
    "buster" : {
      case "$env::deb_arch" {
        "amd64": {
          $driver_source = 'http://packages.grid5000.fr/other/cuda/cuda_10.1.243_418.87.00_linux.run'
          $libcuda = '/usr/lib/x86_64-linux-gnu/libcuda.so'
        }
        "ppc64el": {
          $driver_source = 'http://packages.grid5000.fr/other/cuda/cuda_10.1.243_418.87.00_linux_ppc64le.run'
          $libcuda = '/usr/lib/powerpc64le-linux-gnu/libcuda.so'
        }
        default: {
          err "${env::deb_arch} not supported"
        }
      }

      $opengl_packages = ['ocl-icd-libopencl1', 'opencl-headers']

      exec{
        'retrieve_nvidia_cuda':
          command   => "/usr/bin/wget -q $driver_source -O /tmp/NVIDIA-Linux_cuda.run && chmod u+x /tmp/NVIDIA-Linux_cuda.run",
          timeout   => 1200, # 20 min
          creates   => "/tmp/NVIDIA-Linux_cuda.run";
        'install_nvidia_cuda':
          command     => "/tmp/NVIDIA-Linux_cuda.run --silent --toolkit --samples && /bin/rm /tmp/NVIDIA-Linux_cuda.run",
          timeout     => 2400, # 20 min
          user        => root,
          environment => ["HOME=/root", "USER=root"], # prevent cuda installer to failed when copying sample files (default sample path : $(HOME)/NVIDIA_CUDA-10.1_Samples, cf. https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#runfile-advanced)
          require     =>  File['/tmp/NVIDIA-Linux_cuda.run'];
        'update_ld_conf':
          command   => "/sbin/ldconfig",
          user      => root,
          refreshonly => true;
      }
    }

    "stretch" : {
      $driver_source = 'http://packages.grid5000.fr/other/cuda/cuda_9.0.176_384.81_linux-run'
      $opengl_packages = ['ocl-icd-libopencl1', 'opencl-headers']
      $libcuda = '/usr/lib/x86_64-linux-gnu/libcuda.so'

      exec{
        'retrieve_nvidia_cuda':
          command   => "/usr/bin/wget -q $driver_source -O /tmp/NVIDIA-Linux_cuda.run && chmod u+x /tmp/NVIDIA-Linux_cuda.run",
          timeout   => 1200, # 20 min
          creates   => "/tmp/NVIDIA-Linux_cuda.run";
        'install_nvidia_cuda':
          command     => "/tmp/NVIDIA-Linux_cuda.run --silent --toolkit --samples && /bin/rm /tmp/NVIDIA-Linux_cuda.run",
          timeout     => 2400, # 20 min
          user        => root,
          require     =>  File['/tmp/NVIDIA-Linux_cuda.run'];
        'update_ld_conf':
          command   => "/sbin/ldconfig",
          user      => root,
          refreshonly => true;
      }
    }
  }

  case "${::lsbdistcodename}" {
    "stretch", "buster" : {
      file{
        '/tmp/NVIDIA-Linux_cuda.run':
          ensure    => file,
          require   => Exec['retrieve_nvidia_cuda'];
        '/usr/local/cuda/lib64/libcuda.so':
          ensure    => 'link',
          target    => $libcuda,
          require   => Exec['install_nvidia_cuda'],
          notify    => Exec['update_ld_conf'];
        '/etc/ld.so.conf.d/cuda.conf':
          ensure    => file,
          owner     => root,
          group     => root,
          mode      => '0644',
          source    => 'puppet:///modules/env/big/nvidia/cuda.conf',
          notify    => Exec['update_ld_conf'];
        '/etc/systemd/system/nvidia-persistenced.service':
          ensure    => file,
          owner     => root,
          group     => root,
          mode      => '0644',
          source    => 'puppet:///modules/env/big/nvidia/nvidia-persistenced-9.0.service';
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
