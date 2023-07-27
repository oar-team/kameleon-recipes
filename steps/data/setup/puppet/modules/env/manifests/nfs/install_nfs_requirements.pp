class env::nfs::install_nfs_requirements () {

  package {
    'nfs-common':
      ensure   => installed;
    'libcap2-bin':
      ensure   => installed;
  }

  case "${::lsbdistcodename}" {
    "buster": {
      # NOTHING
    }
    "bullseye" : {
      # Force python3 usage instead of python2 (only 'python' is Recommended by nfs-common package)
      # see bug #13194
      package {
        'python-is-python3':
          ensure => installed;
      }
    }
    default : {
      fail "${::lsbdistcodename} not supported."
    }
  }
}
