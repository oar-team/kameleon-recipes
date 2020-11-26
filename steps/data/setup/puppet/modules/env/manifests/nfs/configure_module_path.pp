class env::nfs::configure_module_path () {

  # Install lmod from g5k repository (bug 12200)
  # Remove when Debian buster 10.7 is released:
  # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=972963
  # When removing, update the "require" of the other resource below.
  env::common::g5kpackages {
    'lmod':
       ensure => $::env::common::software_versions::lmod;
  }

  # Configure module path (installed in g5k-metapackage)
  file {
    '/etc/lmod/modulespath':
      ensure   => file,
      backup   => '.puppet-bak',
      content  => "/grid5000/spack/share/spack/modules/linux-debian9-x86_64\n/grid5000/spack/share/spack/modules/linux-debian10-x86_64\n",
      require  => [
        Env::Common::G5kpackages['g5k-meta-packages'],
        Env::Common::G5kpackages['lmod']
     ];
  }
}
