class env::nfs::install_nfs_requirements () {

  package {
    'nfs-common':
      ensure   => installed;
    'libcap2-bin':
      ensure   => installed;
  }
}
