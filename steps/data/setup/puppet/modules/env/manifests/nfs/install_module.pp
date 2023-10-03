class env::nfs::install_module () {

  case "${::lsbdistcodename}" {
    "buster": {
      # NOTHING
    }
    "bullseye", "bookworm" : {
      # Install lmod from g5kpackages (custom version that includes module-stats-wrapper)
      # Otherwise, for debian 10, lmod is installed with g5k-meta-packages
      env::common::g5kpackages {
        "lmod":
          release => "${::lsbdistcodename}",
          ensure => $::env::common::software_versions::lmod;
      }
    }
    default : {
      fail "${::lsbdistcodename} not supported."
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
}
