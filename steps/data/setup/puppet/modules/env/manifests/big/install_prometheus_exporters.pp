class env::big::install_prometheus_exporters {

  package {
    'prometheus-node-exporter':
      ensure => installed;
  }

  file {
    '/etc/default/prometheus-node-exporter':
      require => Package['prometheus-node-exporter'],
      content => file('env/big/prometheus/prometheus-node-exporter.default'),
      owner   => root,
      group   => root,
      mode    => '0644',
  }

}
