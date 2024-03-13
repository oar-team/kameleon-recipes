class env::big::configure_nvidia_gpu::fabricmanager_deb () {

### This class exists for GPU clusters equipped with nvswitch technology
### that require the fabricmanager driver
### Installation is provides by the usage of a deb packages
  $nvfabric_vars = split($::env::common::software_versions::nvidia_fabricmanager, '_')
  $nvfabric_major = $nvfabric_vars[0]
  $nvfabric_version = $nvfabric_vars[1]
  Package{ 'nvidia-fabricmanager':
    name => "nvidia-fabricmanager-$nvfabric_major",
    ensure => $nvfabric_version,
    require => Env::Common::G5kpackages['nvidia-dcgm-exporter'];
  }
}
