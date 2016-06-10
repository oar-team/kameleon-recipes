class env::nfs::install_storage5k_requirements {

  #Package required by storage5k
  package {
    "libdbd-pg-perl":
      ensure  => installed;
  }
}
