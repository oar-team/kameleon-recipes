class env::big::configure_nvidia_gpu::ganglia () {

  case $operatingsystem {
    'Debian','Ubuntu': {
      # This package is retrieve from www.grid5000.fr. I guess this is because it needs to be retrievable from outside of g5k.
      exec{'retrieve_ganglia-monitor-python-nvidia_deb':
        command => "/usr/bin/wget --no-check-certificate -q https://www.grid5000.fr/packages/debian/ganglia-monitor-python-nvidia_0.1.deb -O /tmp/ganglia-monitor-python-nvidia.deb",
        creates => "/tmp/ganglia-monitor-python-nvidia.deb";
      }
      package {
        'ganglia-monitor-python-nvidia':
          ensure   => installed,
          provider => dpkg,
          source   => "/tmp/ganglia-monitor-python-nvidia.deb",
          require  =>  [
              Exec['retrieve_ganglia-monitor-python-nvidia_deb'],
              Package['ganglia-monitor']
          ]
      }
      file{
        '/etc/ganglia/conf.d/modpython-nvidia.conf':
          ensure  => file,
          owner   => root,
          group   => root,
          mode    => '0644',
          source  => "puppet:///modules/env/big/nvidia/modpython-nvidia.conf",
          require => Package['ganglia-monitor-python-nvidia'];
      }
    }
    default: {
      err "${operatingsystem} not suported."
    }
  }

}
