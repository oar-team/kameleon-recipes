class env::std::configure_oar_client {

  $oar_packages = ['oar-common', 'oar-node']

  if "$operatingsystem" == "Debian" {
    # Can specify oar client version below
    case "${::lsbdistcodename}" {
      'stretch' : {
        $oar_version       = "2.5.9~g5k3-1~bpo10+1";
        $oar_repos         = "2.5/debian/";
        $oar_repos_release = "stretch-backports_beta"
      }
      'buster' : {
        $oar_version       = "2.5.9~g5k3-1~bpo10+1";
        $oar_repos         = "2.5/debian/";
        $oar_repos_release = "buster-backports_beta"
      }
    }
  }

  if ($oar_repos == "default") {
    package {
      'oar-common':
        ensure   => $oar_version,
        require  => Package["liboar-perl"];
      'oar-node':
        ensure   => $oar_version,
        require  => Package["liboar-perl"];
      'liboar-perl':
        ensure   => $oar_version;
    }
  } else {
    apt::source {
      'oar-repo':
        location => "http://oar-ftp.imag.fr/oar/$oar_repos",
        release  => "$oar_repos_release",
        repos    => 'main',
        notify   => Exec['oar apt update'],
        require  => Exec["import oar gpg key"],
    }
    exec {
      "import oar gpg key":
        command => "/usr/bin/wget -q http://oar-ftp.imag.fr/oar/oarmaster.asc -O- | /usr/bin/apt-key add -",
        unless  => "/usr/bin/apt-key list | /bin/grep oar",
    }
    exec {
      "oar apt update":
        command => "/usr/bin/apt-get update",
    }
    package {
      'oar-common':
        ensure          => $oar_version,
        install_options => ['-t', "$oar_repos_release"],
        require         => [ Package["liboar-perl"], Apt::Source['oar-repo'] ];
      'oar-node':
        ensure          => $oar_version,
        install_options => ['-t', "$oar_repos_release"],
        require         => [ Package["liboar-perl"], Apt::Source['oar-repo'] ];
      'liboar-perl':
        ensure          => $oar_version,
        install_options => ['-t', "$oar_repos_release"],
        require         => Apt::Source['oar-repo'];
    }
  }

  if ($oar_version != "installed") {
    apt::pin { 'oar client pin':
      packages => [ 'oar-common', 'oar-node', 'liboar-perl' ],
      version  => $oar_version,
      priority => 1001,
    }
  }

  $hiera   = lookup("env::std::oar::ssh")
  file {
    '/var/lib/oar/checklogs/':
      ensure   => directory,
      owner    => root,
      group    => root,
      mode     => '0755',
      require  => Package[$oar_packages];
    '/var/lib/oar/.ssh':
      ensure   => directory,
      owner    => oar,
      group    => oar,
      mode     => '0755',
      require  => Package[$oar_packages];
    '/var/lib/oar/.ssh/config':
      ensure   => present,
      owner    => oar,
      group    => oar,
      mode     => '0644',
      source   => 'puppet:///modules/env/std/oar/oar_sshclient_config',
      require  => [ File['/var/lib/oar/.ssh'], Package[$oar_packages] ];
    '/etc/oar/oar_ssh_host_dsa_key':
      ensure   => present,
      owner    => root,
      group    => root,
      mode     => '0600',
      content  => $hiera['oar_ssh_host_dsa_key'],
      require  => Package[$oar_packages];
    '/etc/oar/oar_ssh_host_rsa_key':
      ensure   => present,
      owner    => root,
      group    => root,
      mode     => '0600',
      content  => $hiera['oar_ssh_host_rsa_key'],
      require  => Package[$oar_packages];
    '/etc/oar/oar_ssh_host_dsa_key.pub':
      ensure   => present,
      owner    => root,
      group    => root,
      mode     => '0600',
      content  => $hiera['oar_ssh_host_dsa_key_pub'],
      require  => Package[$oar_packages];
    '/etc/oar/oar_ssh_host_rsa_key.pub':
      ensure   => present,
      owner    => root,
      group    => root,
      mode     => '0600',
      content  => $hiera['oar_ssh_host_rsa_key_pub'],
      require  => Package[$oar_packages];
    '/var/lib/oar/.batch_job_bashrc':
      ensure   => present,
      owner    => oar,
      group    => oar,
      mode     => '0755',
      source   => 'puppet:///modules/env/std/oar/batch_job_bashrc',
      require  => Package[$oar_packages];
    '/etc/security/access.conf':
      ensure   => present,
      owner    => root,
      group    => root,
      mode     => '0644',
      source   => 'puppet:///modules/env/std/oar/etc/security/access.conf',
      require  => Package[$oar_packages];
    '/var/lib/oar/access.conf':
      ensure   => present,
      owner    => root,
      group    => root,
      mode     => '0644',
      source   => 'puppet:///modules/env/std/oar/var/lib/oar/access.conf',
      require  => Package[$oar_packages];
    '/etc/oar/sshd_config':
      ensure   => present,
      owner    => root,
      group    => root,
      mode     => '0644',
      source   => '/etc/ssh/sshd_config',
      require  => Package[$oar_packages, 'ssh server'];
    '/var/lib/oar/.ssh/authorized_keys':
      ensure   => present,
      owner    => oar,
      group    => oar,
      mode     => '0644',
      content  => $hiera['oar_authorized_keys'],
      require  => Package[$oar_packages];
    '/etc/default/oar-node':
      ensure   => present,
      owner    => root,
      group    => root,
      mode     => '0644',
      source   => 'puppet:///modules/env/std/oar/default_oar-node',
      require  => Package[$oar_packages];
  }

  augeas {
    'sshd_config_oar':
      incl    => '/etc/oar/sshd_config',
      lens    => 'Sshd.lns',
      changes => [
        'set /files/etc/oar/sshd_config/Port 6667',
        'set /files/etc/oar/sshd_config/HostKey /etc/oar/oar_ssh_host_rsa_key',
        'set /files/etc/oar/sshd_config/LoginGraceTime 10m',
        'set /files/etc/oar/sshd_config/PermitRootLogin no',
        'set /files/etc/oar/sshd_config/PasswordAuthentication no',
        'set /files/etc/oar/sshd_config/ChallengeResponseAuthentication no',
        'set /files/etc/oar/sshd_config/UsePAM yes',
        'set /files/etc/oar/sshd_config/X11Forwarding yes',
        'set /files/etc/oar/sshd_config/PrintMotd no',
        'set /files/etc/oar/sshd_config/PermitUserEnvironment yes',
        'set /files/etc/oar/sshd_config/MaxStartups 500',
        'set /files/etc/oar/sshd_config/AcceptEnv/1 LANG',
        'set /files/etc/oar/sshd_config/AcceptEnv/2 LC_*',
        'set /files/etc/oar/sshd_config/AcceptEnv/3 OAR_CPUSET',
        'set /files/etc/oar/sshd_config/AcceptEnv/4 OAR_JOB_USER',
        'set /files/etc/oar/sshd_config/Subsystem/sftp /usr/lib/openssh/sftp-server',
        'set /files/etc/oar/sshd_config/AllowUsers/1 oar'
      ],
      require  => File['/etc/oar/sshd_config'];
  }

  if $env::target_g5k {
    $key_values   = lookup("env::std::oar::ssh")

    file {
      "/var/lib/oar/.ssh/oarnodesetting_ssh.key":
        ensure   => file,
        owner    => oar,
        group    => oar,
        mode     => '0600',
        content  => $key_values['oarnodesetting_ssh_key'];
      "/var/lib/oar/.ssh/oarnodesetting_ssh.key.pub":
        ensure   => file,
        owner    => oar,
        group    => oar,
        mode     => '0644',
        content  => $key_values['oarnodesetting_ssh_key_pub'];
      "/var/lib/oar/.ssh/id_rsa":
        ensure   => file,
        owner    => oar,
        group    => oar,
        mode     => '0600',
        content  => $key_values['id_rsa'];
      "/var/lib/oar/.ssh/id_rsa.pub":
        ensure   => file,
        owner    => oar,
        group    => oar,
        mode     => '0644',
        content  => $key_values['id_rsa_pub'];
    }
  }
}
