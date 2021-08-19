class env::big::configure_nvidia_gpu::ganglia () {

  case $operatingsystem {
    'Debian': {

      case "${::lsbdistcodename}" {
        'buster' : {
          env::common::g5kpackages {
            'ganglia-monitor-nvidia':
              packages => 'ganglia-monitor-python-nvidia',
              ensure => installed;
          }

          Package['ganglia-monitor'] -> Package['ganglia-monitor-python-nvidia']

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
          exec {
            'Enable ganglia on startup':
              command => "systemctl enable ganglia-monitor",
              path    => ['/bin','/usr/bin','/sbin'];
          }
        }
        default : {
          # No more ganglia since bullseye
        }
      }
    }
    default: {
      err "${operatingsystem} not supported."
    }
  }

}
