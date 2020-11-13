class env::big::configure_nvidia_gpu::prometheus () {

  case $operatingsystem {
    'Debian','Ubuntu': {

      env::common::g5kpackages {
        'nvidia-dcgm-exporter':
          packages => ['dcgm-exporter', 'datacenter-gpu-manager'],
          ensure => installed;
      }

      file{
        '/etc/systemd/system/dcgm-exporter.service':
          ensure  => file,
          owner   => root,
          group   => root,
          mode    => '0644',
          source  => "puppet:///modules/env/big/nvidia/dcgm-exporter.service";
      }
      service {
       'dcgm.service':
         enable => false,
         require => Package['datacenter-gpu-manager'];
       'dcgm-exporter.service':
         enable => true,
         require => [File['/etc/systemd/system/dcgm-exporter.service'], Package['dcgm-exporter']];
      }
    }
    default: {
      err "${operatingsystem} not suported."
    }
  }

}
