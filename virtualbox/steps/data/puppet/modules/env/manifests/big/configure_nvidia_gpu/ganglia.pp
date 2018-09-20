class env::big::configure_nvidia_gpu::ganglia () {

  case $operatingsystem {
    'Debian','Ubuntu': {

      apt::source { 'ganglia-monitor-nvidia':
        key      => {
          'id'      => '3C38BDEAA05D4A7BED7815E5B1F34F56797BF2D1',
          'content' => file('env/min/apt/grid5000-archive-key.asc')
        },
        comment  => 'Grid5000 repository for ganglia-monitor-nvidia',
        location => 'http://packages.grid5000.fr/deb/ganglia-monitor-nvidia/',
        release  => "/",
        repos    => '',
        include  => { 'deb' => true, 'src' => false }
      }

      package {
        'ganglia-monitor-python-nvidia':
          ensure   => installed,
          require  =>  [
            Class['apt::update'],
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
    default: {
      err "${operatingsystem} not suported."
    }
  }

}
