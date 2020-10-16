class env::big::install_prometheus_exporters {

  package {
    'prometheus-node-exporter':
      ensure => installed;
  }

}
