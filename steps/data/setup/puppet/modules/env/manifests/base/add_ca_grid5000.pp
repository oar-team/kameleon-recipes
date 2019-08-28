# Add ca2019.grid5000.fr certificate

class env::base::add_ca_grid5000 {

  exec {
    'get_ca2019':
      command => "/usr/bin/wget --no-check-certificate -q https://www.grid5000.fr/certs/ca2019.grid5000.fr.crt -O /usr/local/share/ca-certificates/ca2019.grid5000.fr.crt",
      creates => "/usr/local/share/ca-certificates/ca2019.grid5000.fr.crt";
    'update_ca':
      command => "/usr/sbin/update-ca-certificates",
      require => Exec['get_ca2019'];
    }

}
