class env::big::configure_nvidia_gpu::ganglia () {

  case $operatingsystem {
    'Debian','Ubuntu': {

      env::common::g5kpackages {
        'ganglia-monitor-nvidia':
          packages => 'ganglia-monitor-python-nvidia',
          ensure => installed,
          require  =>  Package['ganglia-monitor']
      }

      file{
        '/etc/ganglia/conf.d/modpython-nvidia.conf':
          ensure  => file,
          owner   => root,
          group   => root,
          mode    => '0644',
          source  => "puppet:///modules/env/big/nvidia/modpython-nvidia.conf",
          require => Package['ganglia-monitor-python-nvidia'];
        '/etc/systemd/system/ganglia-monitor.service':
          ensure  => file,
          owner   => root,
          group   => root,
          mode    => '0644',
          source  => "puppet:///modules/env/big/nvidia/ganglia-monitor.service";
      }
      # FIXME ne devrait-on pas utiliser une ressource Service plutot ici ?
      exec {
       'Enable ganglia on startup':
         command => "systemctl enable ganglia-monitor",
         path    => ['/bin','/usr/bin','/sbin'];
      }
    }
    default: {
      err "${operatingsystem} not suported."
    }
  }

}
