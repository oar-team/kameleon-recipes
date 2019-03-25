class env::nfs::configure_module_path () {

  # Configure module path (installed in g5k-metapackage)
  file {
    '/etc/environment-modules/modulespath':
      ensure   => file,
      backup   => '.puppet-bak',
      content  => '/grid5000/spack/share/spack/modules/linux-debian9-x86_64',
      require  => Env::Common::G5kpackages['g5k-meta-packages'];
  }
}
