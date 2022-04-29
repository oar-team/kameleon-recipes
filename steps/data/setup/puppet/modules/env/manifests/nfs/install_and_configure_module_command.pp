class env::nfs::install_and_configure_module_command () {

  if ($::lsbdistcodename != 'buster') {
    # Install lmod from g5kpackages (custom version that includes module-stats-wrapper)
    # Otherwise, for debian 10, lmod is installed with g5k-meta-packages
    env::common::g5kpackages {
      "lmod":
        release => "${::lsbdistcodename}",
        ensure => $::env::common::software_versions::lmod;
    }
  }

  # Configure module path
  case "$env::deb_arch" {
    "amd64": {
      case "${::lsbdistcodename}" {
        "bullseye" : {
          # Bug 13590
          $modulespath = "/grid5000/spack/share/spack/modules/linux-debian10-x86_64\n/grid5000/spack/share/spack/modules/linux-debian11-x86_64\n"
        }
        default: {
          $modulespath = "/grid5000/spack/share/spack/modules/linux-debian9-x86_64\n/grid5000/spack/share/spack/modules/linux-debian10-x86_64\n"
        }
      }
    }
    "ppc64el": {
      # No Debian11 ppc64 spack modules (Bug 13722)
      $modulespath = "/grid5000/spack/share/spack/modules/linux-debian10-ppc64le\n"
    }
    default: {
      $modulespath = ""
    }
  }

  if ($::lsbdistcodename != 'buster') {
    $req = [
      Env::Common::G5kpackages['g5k-meta-packages'],
      Env::Common::G5kpackages["lmod"]
    ]
  } else {
    $req = [
      Env::Common::G5kpackages['g5k-meta-packages']
    ]
  }

  file {
    '/etc/lmod/modulespath':
      ensure   => file,
      backup   => '.puppet-bak',
      content  => $modulespath,
      require  => $req;
  }
}
