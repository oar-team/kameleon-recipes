class env::nfs::configure_ntp ( $drift_file = false ) {


  if "${::lsbdistcodename}" == "jessie" {

    $ntp = [ 'openntpd', 'ntpdate' ]
    package {
      'ntpdate':
        ensure    => installed;
      'openntpd':
        ensure    => installed,
        require   => Package['ntp'];
      'ntp':
        ensure    => absent,
        require   => Service['ntp'];
    }

    file {
      '/etc/ntp.conf':
        ensure    => file,
        owner     => root,
        group     => root,
        mode      => '0644',
        content   => template("env/nfs/ntp/ntp.conf.erb"),
        notify    => Service['openntpd'];
    }

    service {
      'openntpd':
        enable    => true;
    }

    service {
      'ntp':
        ensure    => stopped,
        enable    => false;
    }

  } else {

    $ntp = [ 'ntp', 'ntpdate' ]
    package {
      'ntpdate':
        ensure    => installed;
      'ntp':
        ensure    => installed,
        require   => Package['openntpd'];
      'openntpd':
        ensure    => absent;
    }# Here we forced ntp package to be 'ntp' and not 'openntp' because ntp is listed as dependencie by g5kchecks and conflict openntp.

    file {
      '/etc/ntp.conf':
        ensure    => file,
        owner     => root,
        group     => root,
        mode      => '0644',
        content   => template("env/nfs/ntp/ntp.conf.erb"),
        notify    => Service['ntp'];
    }

    if $drift_file {
      file {
        '/var/lib/ntp/ntp.drift':
          ensure    => file,
          owner     => ntp,
          group     => ntp,
          mode      => '0644',
          content   => "",
          require   => Package[$ntp];
      }
    }

    service {
      'ntp':
        enable    => true;
    }
  }
}
