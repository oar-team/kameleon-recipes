# This class provides a wrapper for apt::source to make it easier to install packages from packages.grid5000.fr
# the default value for the 'packages' parameter is the name of the resource. So, you can use, e.g:
#  env::common::g5kpackages {
#   'sudo-g5k':
#      ensure => $::env::common::software_versions::sudo_g5k;
#  }

define env::common::g5kpackages (
  String $source_filename = $name,
  Variant[Array, String] $packages = $name,
  String $ensure = installed,
  String $release = ''
) {
  include apt

  if $::lsbdistcodename != 'bookworm' {
    apt::source { $source_filename:
      key      => {
        'id'      => '3C38BDEAA05D4A7BED7815E5B1F34F56797BF2D1',
        'content' => file('env/min/apt/grid5000-archive-key.asc')
      },
      comment  => "Grid5000 repository for ${name}",
      location => "http://packages.grid5000.fr/deb/${name}/${release}",
      release  => '/',
      repos    => '',
      include  => { 'deb' => true, 'src' => false }
    }
  } else {
    # Debian12: apt-key is deprecated. Manage keyring files in trusted.gpg.d instead. See bug 15510.
    if $::lsbdistcodename == 'bookworm' {
      unless defined(Exec['retrieve_g5k_key']) {
        exec {
        'retrieve_g5k_key':
          command     => "/usr/bin/wget http://packages.grid5000.fr/grid5000-archive-key.gpg -O /usr/share/keyrings/grid5000-archive-key.gpg";
        }
      }
      file { "/etc/apt/sources.list.d/${source_filename}.list":
        ensure  => present,
        content => "deb [signed-by=/usr/share/keyrings/grid5000-archive-key.gpg] http://packages.grid5000.fr/deb/${name}/${release}/ /",
        notify  => Class['apt::update'],
        require => Exec['retrieve_g5k_key'],
      }
    }
  }

  package {
    $packages:
      ensure  => $ensure,
      require => Class['apt::update']
  }
}
