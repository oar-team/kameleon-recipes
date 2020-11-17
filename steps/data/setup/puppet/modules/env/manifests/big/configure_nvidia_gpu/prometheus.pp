class env::big::configure_nvidia_gpu::prometheus () {

  case $operatingsystem {
    'Debian','Ubuntu': {

      env::common::g5kpackages {
        'nvidia-dcgm-exporter':
          packages => 'dcgm-exporter';
      }

      # Version 2.X bumped the SONAME, so we force version 1.X for now
      package {
        'datacenter-gpu-manager':
          ensure  => $::env::common::software_versions::datacenter_gpu_manager,
          require => Env::Common::G5kpackages['nvidia-dcgm-exporter'];
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
