class env::big::configure_nvidia_gpu::cuda () {

  $driver_source = "http://packages.grid5000.fr/other/cuda/cuda_$::env::common::software_versions::nvidia_cuda.run"
  case "$env::deb_arch" {
    "amd64": {
      $libcuda = '/usr/lib/x86_64-linux-gnu/libcuda.so'
      $cuda_args = '--silent'
    }
    "ppc64el": {
      $libcuda = '/usr/lib/powerpc64le-linux-gnu/libcuda.so'
      $cuda_args = '--silent'
    }
  }

  # ncursesw5 is needed for cuda-gdb
  $extra_packages = ['ocl-icd-libopencl1', 'opencl-headers', 'libncursesw5']

  # not install cuda for ppc64el bookworm
  # see https://intranet.grid5000.fr/bugzilla/show_bug.cgi?id=15183
  unless ("$env::deb_arch" == 'ppc64el' and "$lsbdistcodename" == 'bookworm') {
    exec{
      'retrieve_nvidia_cuda':
        command   => "/usr/bin/wget -q $driver_source -O /tmp/NVIDIA-Linux_cuda.run && chmod u+x /tmp/NVIDIA-Linux_cuda.run",
        timeout   => 1200, # 20 min
        creates   => "/tmp/NVIDIA-Linux_cuda.run";
      'install_nvidia_cuda':
        command     => "/tmp/NVIDIA-Linux_cuda.run $cuda_args --toolkit && /bin/rm /tmp/NVIDIA-Linux_cuda.run",
        timeout     => 2400, # 20 min
        user        => root,
        environment => ["HOME=/root", "USER=root"], # prevent cuda installer to failed when copying sample files (default sample path : $(HOME)/NVIDIA_CUDA-10.1_Samples, cf. https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#runfile-advanced)
        require     =>  File['/tmp/NVIDIA-Linux_cuda.run'];
      'update_ld_conf':
        command   => "/sbin/ldconfig",
        user      => root,
        refreshonly => true;
    }

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
        source    => 'puppet:///modules/env/big/nvidia/nvidia-persistenced.service';
      '/etc/systemd/system/multi-user.target.wants/nvidia-persistenced.service':
        ensure => link,
        target => '/etc/systemd/system/nvidia-persistenced.service';
      '/var/log/nvidia-dcgm':
        ensure    => directory,
        owner     => root,
        group     => root,
        require   => Exec['install_nvidia_cuda'];
    }

    file {
      '/etc/profile.d/cuda.sh':
        ensure  => present,
        owner => root,
        group => root,
        mode  => '0644',
        content => 'export PATH=$PATH:/usr/local/cuda/bin';
    }
  }

  package{
    $extra_packages:
      ensure    => installed;
  }

  # Install one or more fake (empty) package(s) to help satisfy libhwloc-contrib-plugins dependencies.
  # No need to force a particular version, newer versions of the package(s) should still be equally empty.
  # cf. bug #12877, #12861 and #13260
  # Using hwloc bullseye-backports packages
  # cf. bug #13571 and #14313
  case "${::lsbdistcodename}" {
    "bookworm" : {
      case "$env::deb_arch" {
        "ppc64el": {
          env::common::g5kpackages {
            'libnvidia-tesla-470-cuda1':
              ensure   => installed;
            'libnvidia-tesla-470-ml1':
              ensure   => installed;
            'libcudart11.0':
              ensure   => installed;
          } -> package {
            ['hwloc', 'libhwloc-contrib-plugins']:
              ensure   => installed;
          }
        }
        default: {
          env::common::g5kpackages {
            'libcuda1':
              ensure   => installed;
            'libnvidia-ml1':
              ensure   => installed;
            'libcudart11.0':
              ensure   => installed;
          } -> package {
            ['hwloc', 'libhwloc-contrib-plugins']:
              ensure   => installed;
          }
        }
      }
    }
    "bullseye" : {
      case "$env::deb_arch" {
        "ppc64el": {
          env::common::g5kpackages {
            'libnvidia-tesla-470-cuda1':
              ensure   => installed;
            'libnvidia-tesla-470-ml1':
              ensure   => installed;
            'libcudart11.0':
              ensure   => installed;
          } -> package {
            ['hwloc', 'libhwloc-contrib-plugins']:
              install_options => ['-t', 'bullseye-backports'],
              ensure   => installed;
          }
        }
        default: {
          env::common::g5kpackages {
            'libcuda1':
              ensure   => installed;
            'libnvidia-ml1':
              ensure   => installed;
            'libcudart11.0':
              ensure   => installed;
          } -> package {
            ['hwloc', 'libhwloc-contrib-plugins']:
              install_options => ['-t', 'bullseye-backports'],
              ensure   => installed;
          }
        }
      }
    }
    'buster': {
      env::common::g5kpackages {
        'libcuda1':
          ensure    => installed;
      } -> package {
        'libhwloc-contrib-plugins':
          ensure    => installed;
      }
    }
    default: {
      fail "${::lsbdistcodename} not supported."
    }
  }
}
