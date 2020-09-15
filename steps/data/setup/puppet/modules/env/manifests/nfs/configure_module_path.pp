class env::nfs::configure_module_path () {

  # Configure module path (installed in g5k-metapackage)
  file {
    '/etc/lmod/modulespath':
      ensure   => file,
      backup   => '.puppet-bak',
      content  => "/grid5000/spack/share/spack/modules/linux-debian9-x86_64\n/grid5000/spack/share/spack/modules/linux-debian10-x86_64\n",
      require  => Env::Common::G5kpackages['g5k-meta-packages'];
  }

  # Hack to workaround a hardcoded x86_64 path in lmod
  # https://intranet.grid5000.fr/bugzilla/show_bug.cgi?id=12200
  if $env::deb_arch == 'arm64' {
    file {
      '/usr/lib/x86_64-linux-gnu':
        ensure   => directory,
        target   => '/usr/lib/aarch64-linux-gnu/lua',
        require  => Env::Common::G5kpackages['g5k-meta-packages'];
    }
    file {
      '/usr/lib/x86_64-linux-gnu/lua':
        ensure   => link,
        target   => '/usr/lib/aarch64-linux-gnu/lua',
        require  => File['/usr/lib/x86_64-linux-gnu'];
    }
  }
}
